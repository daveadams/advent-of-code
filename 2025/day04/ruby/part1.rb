#!/usr/bin/env ruby

class Grid
  def initialize(s)
    rows = s.split("\n")
    @nrows = rows.length
    @ncols = rows[0].length

    @grid = s.split("\n").collect do |row|
      raise unless row.length == @ncols
      row.split('')
    end
  end

  def cell_value(x, y)
    if x < 0 or y < 0 or x >= @nrows or y >= @ncols
      nil
    else
      @grid[x][y]
    end
  end

  def cell_has_paper?(x, y)
    self.cell_value(x, y) == "@"
  end

  def cell_neighbors(x, y)
    neighbors = []
    (x-1..x+1).each do |cx|
      (y-1..y+1).each do |cy|
        neighbors.push([cx, cy]) unless cx == x and cy == y
      end
    end
    neighbors
  end

  def cell_neighbor_paper_count(x, y)
    self.cell_neighbors(x, y).select do |coords|
      self.cell_has_paper?(*coords)
    end.length
  end

  def cell_is_accessible?(x, y)
    self.cell_neighbor_paper_count(x, y) < 4
  end

  def cell_has_accessible_paper?(x, y)
    self.cell_has_paper?(x, y) and self.cell_is_accessible?(x, y)
  end

  def accessible_cell_count
    count = 0
    @grid.each_index do |x|
      @grid[x].each_index do |y|
        count += 1 if self.cell_has_accessible_paper?(x, y)
      end
    end
    count
  end
end

grid = Grid.new(ARGF.read)
puts grid.accessible_cell_count
