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

    if dir == "L"
      count.times { click(-1) }
    else
      count.times { click(1) }
    end
  end

  def click(n)
    raise unless n == 1 or n == -1

    @value = (@value + n) % 100
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
