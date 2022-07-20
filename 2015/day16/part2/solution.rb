#!/usr/bin/env ruby

detections = {
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1,
}

$feature_names = detections.keys.sort

class Sue
  attr_reader :name

  def initialize(name, features)
    @name = name
    @features = $feature_names.collect { |name| [name, nil] }.to_h
    features.each do |k,v|
      @features[k] = v
    end
  end

  def method_missing?(m, *args, &block)
    @features[m]
  end

  # returns true if the sue has exactly the same numbers as the filter, or nil, for each feature
  def match_filter?(filter)
    filter.keys.all? do |name|
      @features[name].nil? or
        case name
        when :cats, :trees then @features[name] > filter[name]
        when :pomeranians, :goldfish then @features[name] < filter[name]
        else @features[name] == filter[name]
        end
    end
  end
end

sues = []

ARGF.each_line do |line|
  if line =~ /^Sue ([0-9]+): (.*)$/
    name = $1
    features = $2.split(", ").collect do |s|
      parts = s.split(": ")
      [parts[0].to_sym, parts[1].to_i]
    end.to_h
    sues.append(Sue.new(name, features))
  end
end

puts sues.select { |sue| sue.match_filter?(detections) }.first.name
