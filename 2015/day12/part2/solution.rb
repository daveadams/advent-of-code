#!/usr/bin/env ruby

require 'json'

def analyze(doc)
  case doc
  when Numeric
    doc
  when String, NilClass
    0
  when Array
    doc.collect { |v| analyze(v) }.sum
  when Hash
    hash_sum = 0
    doc.values.each do |v|
      return 0 if v == "red"
      hash_sum += analyze(v)
    end
    hash_sum
  else
    STDERR.puts "Unknown type: #{doc.class}"
    0
  end
end

puts analyze(JSON.parse(ARGF.read))
