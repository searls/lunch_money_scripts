require "date"
require "bigdecimal"
require_relative "helpers"
require_relative "../cli"
require_relative "../api_key"
require_relative "../api"

Month = Struct.new(:year, :month, keyword_init: true)

module Commands
  module SummarizeTransactions
    class << self
      include Helpers
    end

    def self.call(options)
      # Tell the user what's up
      unless options.confirm || Cli.confirm(<<~MSG, default: true)
        This script will download your LunchMoney transactions
        and summarize a given month's spending in a few ways.

        Proceed?
      MSG
        Cli.out "Exiting"
        exit 0
      end

      require_api_key!(options)

      # Ask for a start date
      options.start_date ||= ask_date "(YYYY-MM-DD)", "How far back do you want to search transactions?"
      options.month ||= ask_date "(YYYY-MM)", "Which month do you want to summarize?"

      # Search for ungrouped, non-recurring transactions
      transactions = Api.get(
        api_key: options.api_key,
        path: "transactions",
        options: {start_date: options.start_date, end_date: Date.today.succ}
      ).reject { |t| t["group_id"] || t["recurring_id"] }

      transactions.partition { |t| t["amount"].start_with?("-") }
      binding.irb

      Cli.out <<~MARKDOWN
        ## Hi cool.
      MARKDOWN
    end
  end
end
