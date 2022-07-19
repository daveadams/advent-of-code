#!/usr/bin/env ruby

require 'json'

$sum = 0

def analyze(doc)
  case doc
  when Numeric
    $sum += doc
  when String, NilClass
    # do nothing
  when Array
    doc.each { |v| analyze(v) }
  when Hash
    doc.each do |k,v|
      analyze(k)
      analyze(v)
    end
  else
    STDERR.puts "Unknown type: #{doc.class}"
  end
end

analyze(JSON.parse(ARGF.read))

puts $sum
