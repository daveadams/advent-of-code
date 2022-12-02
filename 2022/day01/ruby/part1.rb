#!/usr/bin/env ruby
puts ARGF.read.split("\n\n").collect { |elf| elf.strip.split("\n").collect(&:to_i).sum }.sort.last(1).sum
