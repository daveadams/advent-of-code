package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	goal, err := strconv.Atoi(os.Args[1])
	if err != nil {
		panic(err)
	}

	for house := 1; ; house++ {
		count := 0
		elfCount := 0
		for elf := 1; elf <= house; elf++ {
			if house%elf == 0 {
				elfCount++
				count += (elf * 10)
			}
		}
		if count >= goal {
			fmt.Println(house)
			os.Exit(0)
		}
		if house%1000 == 0 {
			fmt.Printf("House %d got %d presents from %d elves!\n", house, count, elfCount)
		}
	}
}
