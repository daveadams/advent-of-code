#!/usr/bin/env ruby

class Santa
  attr_accessor :x, :y, :history

  def initialize
    self.x = 0
    self.y = 0
    self.history = {}
    self.remember
  end

  def remember
    self.history[[self.x, self.y]] ||= 0
    self.history[[self.x, self.y]] += 1
  end

  def homes_visited
    self.history.keys.count
  end

  def move(c)
    case c
    when '^' then self.y += 1
    when '>' then self.x += 1
    when '<' then self.x -= 1
    when 'v' then self.y -= 1
    else
      STDERR.puts "ERROR: invalid move '#{c}'"
      exit 1
    end
    self.remember
  end

  def to_s
    "x: #{x}, y: #{y}"
  end
end

santa = Santa.new

ARGF.read.each_char do |c|
  next if c == "\n"
  santa.move(c)
end

puts santa.homes_visited
