#!/usr/bin/env ruby

def is_invalid(id)
  sid = id.to_s
  sid.slice(0,sid.length/2) == sid.slice(sid.length/2,sid.length)
end

class Range
  def initialize(s)
    raise unless s =~ /^([0-9]+)-([0-9]+)$/
    @start = $1
    @end = $2
  end

  def to_s
    "#{@start}-#{@end}"
  end

  def invalid_ids
    return [] if @start.length == @end.length and @start.length.odd?

    nstart = @start.to_i
    nend = @end.to_i

    start_prefix = @start.slice(0,@start.length/2).to_i
    end_prefix = @end.slice(0,(@end.length+1)/2).to_i

    (start_prefix..end_prefix).collect do
      n = "#{it}#{it}".to_i
      n if n >= nstart and n <= nend
    end.compact
  end
end

ranges = ARGF.read.chomp.split(',').collect { Range.new(it) }

puts ranges.collect(&:invalid_ids).flatten.inject(:+)
