#!/usr/bin/env ruby

lines = ARGF.readlines(chomp: true).map(&:reverse)
ops = lines.pop.strip.split(/ +/)

rotated = 0.upto(lines.first.length-1).collect do |i|
  lines.collect { it[i] }
end.collect do
  it.join.strip
end.chunk do
  it == ""
end.collect do |_, x|
  x
end.select do
  it[0] != ""
end

sum = 0
0.upto(ops.length - 1) do |i|
  sum += rotated[i].collect { it.to_i }.inject(ops[i].to_sym)
end
puts sum
