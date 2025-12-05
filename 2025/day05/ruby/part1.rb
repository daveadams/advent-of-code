#!/usr/bin/env ruby

class Range
  attr_reader :start, :end

  def initialize(s, e)
    @start = s.to_i
    @end = e.to_i
  end

  def contains?(n)
    n.between?(@start, @end)
  end

  def overlaps?(other)
    other.start.between?(@start, @end) or
      other.end.between?(@start, @end) or
      @start.between?(other.start, other.end) or
      @end.between?(other.start, other.end)
  end

  def merge(other)
    Range.new([@start, other.start].min, [@end, other.end].max)
  end
end

class FreshnessDatabase
  def initialize
    @ranges = []
  end

  def <<(r)
    @ranges.push(r)
  end

  def fresh?(id)
    @ranges.any? { it.contains?(id.to_i) }
  end
end

db = FreshnessDatabase.new

# read ranges into database
ARGF.each_line do |line|
  break if line =~ /^$/
  db << Range.new(*line.split('-'))
end

fresh = 0

# read ingredient IDs
ARGF.each_line do |id|
  fresh += 1 if db.fresh?(id)
end

puts fresh
