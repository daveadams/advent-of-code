#!/usr/bin/env ruby

MAX_TSP = 100
CALORIE_TARGET = 500

$ingredients = {}
$property_names = []

class Ingredient
  attr_accessor :name, :props

  def initialize(name, props)
    @name = name
    @props = props
  end
end

ARGF.each_line do |line|
  if line =~ /^([A-Za-z]+): (.+)$/
    name = $1.to_sym
    props = $2.split(", ").collect do |prop|
      prop_name_str, val_str = *prop.split(" ")
      $property_names.append(prop_name_str.to_sym)
      [prop_name_str.to_sym, val_str.to_i]
    end.to_h
    $ingredients[name] = Ingredient.new(name, props)
  end
end
$property_names.uniq!
$property_names -= [:calories]

def generate_arrays(base: , low: 1, high: 100)
  (low..high).collect_concat do |i|
    base.collect_concat do |b|
      [b + [i]]
    end
  end.reject do |a|
    a.sum > MAX_TSP
  end
end

$ingredient_names = $ingredients.keys.sort

class Recipe
  def initialize(amounts)
    @amounts = {}
    $ingredient_names.each_index do |idx|
      @amounts[$ingredient_names[idx]] = amounts[idx]
    end
  end

  def score
    return @score unless @score.nil?

    props = $property_names.collect do |name|
      [name, 0]
    end.to_h

    @amounts.each do |name, amt|
      ing = $ingredients[name]
      $property_names.each do |prop|
        props[prop] += (ing.props[prop] * amt)
      end
    end

    @score = props.values.collect { |x| [x,0].max }.inject(:*)
  end

  def calories
    return @calories unless @calories.nil?

    @calories = @amounts.collect do |name, amt|
      $ingredients[name].props[:calories] * amt
    end.sum
  end
end

recipes = [[]]
$ingredients.each do
  recipes = generate_arrays(base: recipes)
end
recipes.select! { |a| a.sum == MAX_TSP }
recipes.collect! { |a| Recipe.new(a) }
recipes.select! { |r| r.calories == CALORIE_TARGET }
puts recipes.collect { |r| r.score }.max
