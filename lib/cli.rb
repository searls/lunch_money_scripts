require "readline"
require_relative "string_stuff"

module Cli
  def self.out(s, prefix: "->")
    puts "#{prefix} #{StringStuff.hanging_indent(s)}"
  end

  def self.in(msg = nil, prompt: "")
    out(msg) if msg
    print "#{prompt}> "
    Readline.readline.strip
  end

  def self.confirm(msg, default: false)
    if default
      confirmation = self.in(msg, prompt: "[Y/n] ")
      !confirmation.downcase.start_with?("n")
    else
      confirmation = self.in(msg, prompt: "[y/N] ")
      confirmation.downcase.start_with?("y")
    end
  end
end
