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
  end
end
