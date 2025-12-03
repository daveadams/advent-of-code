#!/usr/bin/env ruby

def is_invalid(id)
  sid = id.to_s
  (1..sid.length/2).each do |prefix_length|
    prefix = sid.slice(0, prefix_length)
    repeats = sid.length / prefix.length
    return true if (prefix * repeats) == sid
  end
  return false
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

  def start_prefixes
    if @start.length/2 == 0
      ["0"]
    else
      (1..(@start.length/2)).collect do |n|
        @start.slice(0, n)
      end
    end
  end

  def all_prefixes
    self.start_prefixes.collect do |start_prefix|
      suffix_length = @start.length - start_prefix.length
      end_prefix_length = @end.length - suffix_length
      end_prefix = @end.slice(0, end_prefix_length)
      (start_prefix.to_i..end_prefix.to_i).collect do |mid_prefix|
        midnum = (mid_prefix.to_s + ("0" * suffix_length))
        (1..(midnum.length/2)).collect do |n|
          midnum.slice(0, n)
        end
      end
    end.flatten.uniq
  end

  def suffix_length
    @suffix_length ||= @start.length - (@start.length/2)
  end

  def invalid_ids
    minlen = @start.length
    maxlen = @end.length
    nstart = @start.to_i
    nend = @end.to_i

    self.all_prefixes.collect do |prefix|
      ((minlen/prefix.length)..(maxlen/prefix.length)).collect do |repeats|
        #puts (prefix * repeats)
        (prefix * repeats).to_i
      end
    end.flatten.select do |n|
      n >= nstart and n <= nend
    end.uniq
  end

  def bruteforce_invalid_ids
    (@start.to_i..@end.to_i).select do |n|
      is_invalid(n)
    end
  end
end

ranges = ARGF.read.chomp.split(',').collect { Range.new(it) }

#ranges.each do
#  puts it
#  puts it.bruteforce_invalid_ids.inspect
#  puts
#end

# slow check-every-number method
#puts ranges.collect(&:bruteforce_invalid_ids).flatten.inject(:+)

puts ranges.collect(&:invalid_ids).flatten.inject(:+)
