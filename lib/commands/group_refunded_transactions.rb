require "date"
require "bigdecimal"
require_relative "../cli"
require_relative "../api_key"
require_relative "../api"

module Commands
  module GroupRefundedTransactions
    def self.call(options)
      # Tell the user what's up
      unless options.confirm || Cli.confirm(<<~MSG)
        This script will download your LunchMoney transactions
        and create a transaction group to combine any two transactions
        at a merchant when their values are equal and opposite (as
        if you received a full refund for the transaction).

        This will effectively zero-out the transaction in Lunch Money's
        user interface, as the transactions will offset each other.

        Proceed?
      MSG
        Cli.out "Exiting"
        exit 0
      end

      # Get their API Key if you don't have it
      unless options.api_key ||= ApiKey.load_api_key
        options.api_key = Cli.in("Enter your LunchMoney Access Token")
        ApiKey.store_api_key(api_key)
      end

      # Ask for a start date
      options.start_date ||= Date.parse(Cli.in(
        "How far back do you want to search transactions?",
        prompt: "(YYYY-MM-DD) "
      ))

      # Search for ungrouped transactions
      transactions = Api.get(
        api_key: options.api_key,
        path: "transactions",
        options: {start_date: options.start_date, end_date: Date.today.succ}
      ).reject { |t| t["group_id"] }

      refunds, charges = transactions.partition { |t| t["amount"].start_with?("-") }
      offsetting_transactions = refunds.map { |refund|
        refund_amount = BigDecimal(refund["amount"])
        matching_charges = charges.select { |charge|
          charge_amount = BigDecimal(charge["amount"])
          refund_amount == charge_amount * -1 &&
            refund["currency"] == charge["currency"] &&
            refund["payee"] == charge["payee"] &&
            refund["date"] >= charge["date"]
        }

        [refund, matching_charges] unless matching_charges.empty?
      }.compact.to_h

      offsetting_transactions.each do |(refund, matching_charges)|
        if matching_charges.length == 1
          charge = matching_charges.first
          Cli.out "Payment of #{charge["amount"]} #{charge["currency"].upcase} made to #{charge["payee"]} on #{charge["date"]} was refunded on #{refund["date"]}"
        else
          Cli.out <<~MSG
            Refund of #{refund["amount"]} from #{refund["payee"]} on #{refund["date"]} matches #{matching_charges.length} charges:
            #{matching_charges.map.with_index { |charge, i|
              "  #{i + 1}. #{charge["amount"]} #{charge["currency"].upcase} to #{charge["payee"]} on #{charge["date"]}"
            }.join("\n")}
          MSG
        end
      end

      Cli.out "Total refunds matching transactions: #{offsetting_transactions.keys.map { |t| BigDecimal(t["amount"]) * -1 }.sum.to_f}"
    end
  end
end
