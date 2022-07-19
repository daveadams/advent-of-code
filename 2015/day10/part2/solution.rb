#!/usr/bin/env ruby

def look_and_say(s)
  rv = ""
  while s =~ /^(([1-9])\2*)/
    rv += "#{$1.length}#{$1[0]}"
    s = s.sub(/^#{$1}/, "")
  end
  rv
end

v = File.read("../input")
50.times do
  v = look_and_say(v)
end
puts v.length
