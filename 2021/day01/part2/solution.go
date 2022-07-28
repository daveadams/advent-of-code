package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

func main() {
	raw, _ := ioutil.ReadFile(os.Args[1])

	numbers := []int{}

	for _, line := range strings.Split(string(raw), "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		current, _ := strconv.Atoi(line)
		numbers = append(numbers, current)
	}

	increases := 0
	previous := -1

	for i := 0; i < len(numbers)-2; i++ {
		current := numbers[i] + numbers[i+1] + numbers[i+2]
		if current > previous && previous != -1 {
			increases++
		}
		previous = current
	}

	fmt.Println(increases)
}
