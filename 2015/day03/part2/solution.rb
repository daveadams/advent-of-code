#!/usr/bin/env ruby

class Santa
  attr_accessor :x, :y, :history, :moves

  def initialize
    self.x = 0
    self.y = 0
    self.history = {}
    self.remember
    self.moves = 0
  end

  def remember
    self.history[[self.x, self.y]] ||= 0
    self.history[[self.x, self.y]] += 1
  end

  def homes_visited
    self.history.keys.count
  end

  def unique_homes_visited_with_other_santa(s)
    (self.history.keys + s.history.keys).uniq.count
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
    self.moves += 1
    self.remember
  end

  def to_s
    "x: #{x}, y: #{y}"
  end
end

santa = Santa.new
robo_santa = Santa.new

ARGF.read.each_char do |c|
  next if c == "\n"
  if santa.moves == robo_santa.moves
    santa.move(c)
  else
    robo_santa.move(c)
  end
end

puts santa.unique_homes_visited_with_other_santa(robo_santa)
