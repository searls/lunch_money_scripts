module StringStuff
  def self.hanging_indent(s, indent = "  ")
    s.split("\n").map.with_index { |line, i|
      if i == 0
        line
      else
        "#{indent} #{line}"
      end
    }.join("\n")
  end
end
