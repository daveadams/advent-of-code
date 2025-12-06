#!/usr/bin/env ruby

lines = ARGF.readlines(chomp: true).map(&:strip).collect { it.split(/ +/) }
ops = lines.pop

sum = 0
0.upto(ops.length - 1) do |i|
  sum += lines.collect { it[i].to_i }.inject(ops[i].to_sym)
end
puts sum
