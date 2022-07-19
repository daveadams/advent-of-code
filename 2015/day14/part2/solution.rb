#!/usr/bin/env ruby

reindeer = {}
DURATION = 2503

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

scores = {}
reindeer.keys.each do |name|
  scores[name] = 0
end

1.upto(DURATION) do |sec|
  current_distances = reindeer.collect { |k,v| [k,v.distance_after(sec)] }.to_h
  best_distance = current_distances.values.max
  round_winners = current_distances.select { |k,v| v == best_distance }.keys
  round_winners.each do |name|
    scores[name] += 1
  end
end

puts scores.values.max
