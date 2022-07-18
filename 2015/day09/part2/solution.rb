#!/usr/bin/env ruby

$all_cities = []
$all_paths = {}

ARGF.each_line do |line|
  line.chomp!
  if line =~ /^([A-Za-z]+) to ([A-Za-z]+) = ([0-9]+)$/
    from, to, distance = $1, $2, $3.to_i
    $all_cities += [from, to]
    $all_paths[from] ||= {}
    $all_paths[from][to] = distance
    $all_paths[to] ||= {}
    $all_paths[to][from] = distance
  end
end

$all_cities.uniq!

#puts "Got #{$all_cities.length} cities and #{$all_paths.values.collect { |from| from.keys.length }.sum} paths!"

class Route
  attr_reader :total_distance
  def initialize(itinerary)
    @itinerary = itinerary
    @total_distance = @itinerary.each_cons(2).collect do |pair|
      $all_paths[pair[0]][pair[1]]
    end.sum
  end

  def to_s
    @itinerary.join(" -> ")
  end
end

# recursively build routes
def build_routes(itinerary_cities, remaining_cities)
  if remaining_cities.length < 1
    return [Route.new(itinerary_cities)]
  end
  remaining_cities.collect_concat do |city|
    build_routes(itinerary_cities + [city], remaining_cities - [city])
  end
end

#build_routes([], $all_cities).each do |route|
#  puts "#{route} #{route.total_distance}"
#end

puts build_routes([], $all_cities).collect { |route| route.total_distance }.max
