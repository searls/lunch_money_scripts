module Commands
  module Helpers
    def require_api_key!(options)
      # Get their API Key if you don't have it
      unless options.api_key
        options.api_key = Cli.in("Enter your LunchMoney Access Token")
        ApiKey.store_api_key(options.api_key)
      end
    end

    def ask_date(prompt, message)
      parse_date(Cli.in(
        message,
        prompt: "#{prompt} "
      ))
    end

    # Allows "2022" to be parsed as "2022-01-01", "2022/2" to be "2022-02-01", etc.
    def parse_date(string)
      Date.civil(*string.split(/\W+/).map(&:to_i))
    end

    def to_ym(date)
      date.strftime("%B %Y")
    end

    def cash(amount)
      return if amount.nil?

      "$#{sprintf("%#.2f", amount).gsub(/(\d)(?=(\d{3})+\.)/, '\1,')}"
    end

    def median(values)
      sorted = values.sort
      (sorted[(sorted.size - 1) / 2] + sorted[sorted.size / 2]) / 2.0
    end
  end
end
