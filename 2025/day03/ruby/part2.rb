#!/usr/bin/env ruby

# (set this to '2' to solve part1 with this code)
JOLT_POWER = 12

# recursive_max_joltage takes a list of single-digit joltage values and a
# 'jolt power' rating (which indicates the number of digits the resulting
# joltage must be) and returns the maximum possible joltage (as a multi-
# digit string).
def recursive_max_joltage(s, n)
  # it's a list of strings, but 'max' still works for single digits
  max_digit = s.slice(0, s.length - (n - 1)).max

  if n == 1
    max_digit
  else
    remaining_digits = s.slice(s.find_index(max_digit)+1, s.length)

    # this is string concatenation, not addition
    max_digit + recursive_max_joltage(remaining_digits, n-1)
  end
end

puts(
  ARGF.readlines.collect do |line|
    recursive_max_joltage(line.chomp.split(''), JOLT_POWER).to_i
  end.sum
)
