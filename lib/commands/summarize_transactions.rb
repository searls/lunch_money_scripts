require "date"
require "bigdecimal"
require_relative "helpers"
require_relative "../cli"
require_relative "../api_key"
require_relative "../api"

Month = Struct.new(:year, :month, keyword_init: true) do
  def to_date
    Date.civil(year, month)
  end
end

module Commands
  module SummarizeTransactions
    class << self
      include Helpers
    end

    def self.call(options)
      unless options.confirm || Cli.confirm(<<~MSG, default: true)
        This script will download your LunchMoney transactions
        and summarize a given month's spending in a few ways.

        Proceed?
      MSG
        Cli.out "Exiting"
        exit 0
      end

      require_api_key!(options)

      options.start_date ||= ask_date "(YYYY-MM-DD)", "How far back do you want to search transactions?"
      options.month ||= ask_date "(YYYY-MM)", "Which month do you want to summarize?"

      excluded_categories = Api.get(
        api_key: options.api_key,
        path: "categories",
        options: {}
      ).select { |c| c["exclude_from_totals"] }.map { |c| c["id"] }

      transactions = Api.get(
        api_key: options.api_key,
        path: "transactions",
        options: {start_date: options.start_date, end_date: Date.today.succ}
      ).reject { |t| excluded_categories.include?(t["category_id"]) }

      if transactions.empty?
        raise "No transactions found. Wups!"
      end

      tx_by_month = transactions.group_by { |t|
        y, m, _ = t["date"].split("-").map(&:to_i)
        Month.new(year: y, month: m)
      }

      _, target_month_transactions = tx_by_month.find { |month, _|
        month.to_date == options.month
      }

      monthly_totals = tx_by_month.map { |month, txs|
        [month, txs.sum { |t| BigDecimal(t["amount"]) }]
      }.to_h

      _, target_month_total = monthly_totals.find { |month, _|
        month.to_date == options.month
      }
      year_ago_month, year_ago_month_total = monthly_totals.find { |month, _|
        month == Month.new(year: options.month.year - 1, month: options.month.month)
      }

      total = transactions.sum { |t| BigDecimal(t["amount"]) }
      monthly_mean = total / tx_by_month.size
      monthly_median = median(monthly_totals.values)
      top_transactions = target_month_transactions.sort_by { |t| BigDecimal(t["amount"]) }.reverse.take(20)

      puts <<~MARKDOWN
        ## Spending for #{to_ym(options.month)}

        #{to_ym(options.month)} total: **#{cash target_month_total}**

        #{"Compare to #{cash year_ago_month_total} in #{to_ym year_ago_month.to_date} (one year ago).\n" if year_ago_month_total}
        For context, spending over the last #{tx_by_month.size} months:

          * Average: **#{cash monthly_mean}**
          * Median: **#{cash monthly_median}**
          * Total: **#{cash total}**

        Top #{top_transactions.size} transactions:

        #{top_transactions.map { |t|
          "  * #{t["payee"]} [#{Date.parse(t["date"]).strftime("%-m/%-d")}] - #{cash t["amount"]}"
        }.join("\n")}

      MARKDOWN
    end
  end
end
