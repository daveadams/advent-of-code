#!/usr/bin/env ruby

class Dial
  def initialize
    @value = 50
    @password = 0
  end

  def turn(s)
    raise unless s =~ /^([LR])([0-9]+)$/
    dir = $1
    count = $2.to_i
    count *= -1 if dir == "L"

    @value = (@value + count) % 100
    @password +=1 if @value == 0
  end

  def value
    @value
  end

  def password
    @password
  end
end

dial = Dial.new

ARGF.each_line do
  dial.turn(it)
end

puts dial.password
