package main

import (
	"fmt"
)

func WhichDiagonal(row, col uint64) uint64 {
	return (row + col - 1)
}

func NthDiagonalStart(n uint64) uint64 {
	rv := uint64(0)
	for i := uint64(1); i < n; i++ {
		rv += i
	}
	return rv + 1
}

func ValueAt(row, col uint64) uint64 {
	seq := NthDiagonalStart(WhichDiagonal(row, col))
	rv := uint64(20151125)
	for i := uint64(1); i < (seq + col - 1); i++ {
		rv = (rv * uint64(252533)) % 33554393
	}
	return rv
}

func main() {
	fmt.Println(ValueAt(3010, 3019))
	//	fmt.Printf("   |")
	//	for col := 1; col <= 6; col++ {
	//		fmt.Printf("    %d     ", col)
	//	}
	//	fmt.Printf("\n---+")
	//	for col := 1; col <= 6; col++ {
	//		fmt.Printf("---------+")
	//	}
	//	fmt.Printf("\n")
	//	for row := uint64(1); row <= 6; row++ {
	//		fmt.Printf(" %d |", row)
	//		for col := uint64(1); col <= 6; col++ {
	//			fmt.Printf(" %8d ", ValueAt(row, col))
	//		}
	//		fmt.Printf("\n")
	//	}
}
