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

  def self.confirm(msg)
    confirmation = self.in(msg, prompt: "[y/N] ")
    confirmation.downcase.start_with?("y")
  end
end
