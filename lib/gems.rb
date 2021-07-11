require "bundler/inline"

module Gems
  def self.load
    gemfile do
      source "https://rubygems.org"
      gem "keyring", require: false
      gem "pry", require: false
    end
  end
end

Gems.load
