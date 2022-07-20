#!/usr/bin/env ruby

VOLUME_TARGET = 150

sizes = ARGF.each_line.collect { |line| line.chomp.to_i }
all_combos = (1..sizes.length).collect_concat do |n|
  sizes.combination(n).to_a
end

all_target_combos = all_combos.select { |combo| combo.sum == VOLUME_TARGET }
min_containers = all_target_combos.collect { |combo| combo.length }.min

puts all_target_combos.select { |combo| combo.length == min_containers }.length
