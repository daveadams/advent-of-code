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

    @neighbors = {}
  end

  def cell_has_paper?(x, y)
    @grid[x][y] == "@"
  end

  def cell_neighbors(x, y)
    nkey = "#{x}-#{y}"
    return @neighbors[nkey] if @neighbors[nkey]

    @neighbors[nkey] = []
    (x-1..x+1).each do |cx|
      (y-1..y+1).each do |cy|
        if cx >= 0 and cy >= 0 and cx < @nrows and cy < @ncols
          @neighbors[nkey].push([cx, cy]) unless cx == x and cy == y
        end
      end
    end
    @neighbors[nkey]
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

  def accessible_cells
    cells = []
    @grid.each_index do |x|
      @grid[x].each_index do |y|
        cells.push([x,y]) if self.cell_has_accessible_paper?(x, y)
      end
    end
    cells
  end

  def accessible_cell_count
    self.accessible_cells.length
  end

  def remove_accessible_paper!
    self.accessible_cells.each do |coord|
      x, y = *coord
      @grid[x][y] = "x"
    end
  end
end

grid = Grid.new(ARGF.read)
removed = 0
while grid.accessible_cell_count > 0
  removed += grid.accessible_cell_count
  grid.remove_accessible_paper!
end
puts removed
