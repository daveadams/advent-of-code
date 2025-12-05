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

  def id_count
    @end - @start + 1
  end

  def to_s
    "#{@start}-#{@end}"
  end
end

class FreshnessDatabase
  def initialize
    @ranges = []
  end

  def <<(r)
    # insert range in sorted order
    if i = @ranges.index { it.start >= r.start }
      @ranges.insert(i, r)
    else
      # or at the end
      @ranges.push(r)
    end
  end

  def merge!
    return if @ranges.length < 2

    max = @ranges.length
    i = 0
    while i < max-1 do
      if @ranges[i].overlaps?(@ranges[i+1])
        # merge range i with range i+1 if they overlap
        @ranges[i] = @ranges[i].merge(@ranges[i+1])
        # delete range i+1
        @ranges.delete_at(i+1)
        # and decrement max
        max -= 1
      else
        # if no overlap, move on
        i += 1
      end
    end
  end

  def id_count
    @ranges.map(&:id_count).inject(:+)
  end
end

db = FreshnessDatabase.new

# read ranges into database
ARGF.each_line do |line|
  break if line =~ /^$/
  db << Range.new(*line.split('-'))
end

db.merge!
puts db.id_count
