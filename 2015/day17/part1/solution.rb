#!/usr/bin/env ruby

VOLUME_TARGET = 150

sizes = ARGF.each_line.collect { |line| line.chomp.to_i }
all_combos = (1..sizes.length).collect_concat do |n|
  sizes.combination(n).to_a
end

puts all_combos.select { |combo| combo.sum == VOLUME_TARGET }.length
