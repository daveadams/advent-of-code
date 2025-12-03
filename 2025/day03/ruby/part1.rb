#!/usr/bin/env ruby


class Bank
  def initialize(s)
    @batteries = s.chomp.split('').collect(&:to_i)
  end

  def max_joltage
    max_first_digit = @batteries.slice(0, @batteries.length - 1).max
    max_index = @batteries.find_index(max_first_digit)
    max_second_digit = @batteries.slice(max_index+1, @batteries.length).max

    "#{max_first_digit}#{max_second_digit}".to_i
  end
end

banks = ARGF.read.split("\n").collect { Bank.new(it) }
puts banks.collect(&:max_joltage).sum
