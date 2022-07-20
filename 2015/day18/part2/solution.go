package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func main() {
	rawInput, _ := ioutil.ReadFile(os.Args[1])

	lines := strings.Split(strings.TrimSpace(string(rawInput)), "\n")
	rows := len(lines)
	cols := len(lines[0])

	//fmt.Printf("%d x %d\n", rows, cols)

	grid := make([][]bool, 0, rows)
	for _, line := range lines {
		gridLine := make([]bool, 0, cols)
		for _, char := range []byte(line) {
			gridLine = append(gridLine, char == '#')
		}
		grid = append(grid, gridLine)
	}

	turnOnStuckCorners := func() {
		grid[0][0] = true
		grid[0][cols-1] = true
		grid[rows-1][0] = true
		grid[rows-1][cols-1] = true
	}
	turnOnStuckCorners()

	neighbors := func(row, col int) [][]int {
		rv := [][]int{}
		for _, prow := range []int{row - 1, row, row + 1} {
			if prow < 0 || prow >= rows {
				continue
			}
			for _, pcol := range []int{col - 1, col, col + 1} {
				if pcol < 0 || pcol >= cols {
					continue
				}
				if prow == row && pcol == col {
					continue
				}
				rv = append(rv, []int{prow, pcol})
			}
		}
		return rv
	}

	//fmt.Printf("Neighbors of 0,0:\n%#v\n", neighbors(0, 0))
	//fmt.Printf("Neighbors of 0,1:\n%#v\n", neighbors(0, 1))
	//fmt.Printf("Neighbors of 2,2:\n%#v\n", neighbors(2, 2))

	newState := func(row, col int) bool {
		onCount := 0
		for _, neighbor := range neighbors(row, col) {
			if grid[neighbor[0]][neighbor[1]] {
				onCount++
			}
		}

		//fmt.Printf("Found %d turned-on neighbors for %d,%d (%t)\n", onCount, row, col, grid[row][col])

		if grid[row][col] {
			return (onCount == 2 || onCount == 3)
		} else {
			return (onCount == 3)
		}
	}

	cycle := func() {
		// calculate new state from existing state
		newGrid := [][]bool{}
		for r := 0; r < rows; r++ {
			newGrid = append(newGrid, make([]bool, cols))
			for c := 0; c < cols; c++ {
				newGrid[r][c] = newState(r, c)
			}
		}

		// then overwrite existing state
		for r := 0; r < rows; r++ {
			for c := 0; c < cols; c++ {
				grid[r][c] = newGrid[r][c]
			}
		}

		// keep corners on
		turnOnStuckCorners()
	}

	//printGrid := func() {
	//	for _, row := range grid {
	//		for _, light := range row {
	//			if light {
	//				fmt.Print("#")
	//			} else {
	//				fmt.Print(".")
	//			}
	//		}
	//		fmt.Println()
	//	}
	//	fmt.Println()
	//}

	//printGrid()
	for i := 0; i < 100; i++ {
		//for i := 0; i < 5; i++ {
		cycle()
		//printGrid()
	}

	finalCount := 0
	for r := 0; r < rows; r++ {
		for c := 0; c < cols; c++ {
			if grid[r][c] {
				finalCount++
			}
		}
	}

	fmt.Printf("%d\n", finalCount)
}
