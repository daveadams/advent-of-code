#!/usr/bin/env ruby

nice_count = 0
naughty_count = 0

ARGF.each_line do |line|
  line.chomp!
  next if line == ""

  if line =~ /([a-z][a-z]).*\1/ and line =~ /([a-z])[^\1]\1/
    nice_count += 1
  else
    naughty_count += 1
  end
end

puts nice_count
