#!/usr/bin/env ruby

reindeer = {}

class Reindeer
  attr_reader :name, :speed, :burst, :rest

  def initialize(name, speed, burst, rest)
    @name = name
    @speed = speed.to_i
    @burst = burst.to_i
    @rest = rest.to_i
    @cycle_length = @burst + @rest
  end

  def distance_after(sec)
    full_cycles = sec / @cycle_length
    mod = sec % @cycle_length
    distance = (full_cycles * @burst * @speed) + ([mod, @burst].min * @speed)
  end
end

ARGF.each_line do |line|
  if line =~ /^([A-Za-z]+) can fly ([0-9]+) km\/s for ([0-9]+) seconds, but then must rest for ([0-9]+) seconds.$/
    reindeer[$1] = Reindeer.new($1, $2, $3, $4)
  end
end

puts reindeer.keys.collect { |name| reindeer[name].distance_after(2503) }.max
