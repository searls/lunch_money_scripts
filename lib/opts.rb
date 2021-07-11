require "date"
require "optparse"
require "optparse/date"
require_relative "api_key"

module Opts
  class Options < Struct.new(
    :api_key,
    :start_date,
    :confirm,
    :dry_run,
    keyword_init: true
  )
    def initialize(api_key: ApiKey.load_api_key, confirm: false, dry_run: false, **kwargs)
      super
    end
  end

  def self.parse
    Options.new.tap do |options|
      OptionParser.new { |opts|
        opts.on("--api-key", "--access-token [ACCESS_TOKEN]", String, "Lunch Money Access Token (V1 API Key)") do |api_key|
          ApiKey.store_api_key(api_key)
          options.api_key = api_key
        end

        opts.on("-s", "--start-date [YYYY-MM-DD]", Date, "Start Date") do |start_date|
          options.start_date = start_date
        end

        opts.on("--[no-]confirm", "Automatically confirm prompts") do |confirm|
          options.confirm = confirm
        end

        opts.on("--[no-]dry-run", "Don't make changes in Lunch Money") do |dry_run|
          options.dry_run = dry_run
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit 0
        end
      }.parse!
    end
  end
end
