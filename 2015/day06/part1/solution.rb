#!/usr/bin/env ruby

class Grid
  attr_accessor :lights

  def initialize
    self.lights = []
    (0..999).each do |x|
      self.lights[x] = []
      (0..999).each do |y|
        self.lights[x][y] = false
      end
    end
  end

  def turn_on(x, y)
    self.lights[x][y] = true
  end

  def turn_off(x, y)
    self.lights[x][y] = false
  end

  def toggle(x, y)
    self.lights[x][y] = !self.lights[x][y]
  end

  def turn_on_rectangle(from, to)
    self.all_points_in_rectangle(from, to).each do |point|
      self.turn_on(*point)
    end
  end

  def turn_off_rectangle(from, to)
    self.all_points_in_rectangle(from, to).each do |point|
      self.turn_off(*point)
    end
  end

  def toggle_rectangle(from, to)
    self.all_points_in_rectangle(from, to).each do |point|
      self.toggle(*point)
    end
  end

  def all_points_in_rectangle(from, to)
    Range.new(*[from[0], to[0]].minmax).collect_concat do |x|
      Range.new(*[from[1], to[1]].minmax).collect do |y|
        [x, y]
      end
    end
  end

  def number_of_lights_turned_on
    on_count = 0
    row_num = 0
    self.lights.each do |row|
      col = 0
      row.each do |light|
        #puts "#{row_num},#{col} #{light ? "ON" : "OFF"}"
        on_count += 1 if light
        col += 1
      end
      row_num += 1
    end
    on_count
  end
end

g = Grid.new
#puts g.number_of_lights_turned_on
ARGF.each_line do |line|
  if line =~ /^(turn on|turn off|toggle) ([0-9]{1,3}),([0-9]{1,3}) through ([0-9]{1,3}),([0-9]{1,3})$/
    command = $1
    from = [$2.to_i,$3.to_i]
    to = [$4.to_i,$5.to_i]

    #puts "COMMAND: #{command} #{from} #{to}"

    case command
    when "turn on" then g.turn_on_rectangle(from, to)
    when "turn off" then g.turn_off_rectangle(from, to)
    when "toggle" then g.toggle_rectangle(from, to)
    end
    #puts g.number_of_lights_turned_on
  else
    STDERR.puts "ERROR: LINE DID NOT MATCH: '#{line}'"
  end
end
puts g.number_of_lights_turned_on
