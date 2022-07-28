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

	increases := 0
	previous := -1

	for _, line := range strings.Split(string(raw), "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		current, _ := strconv.Atoi(line)
		if current > previous && previous != -1 {
			increases++
		}
		previous = current
	}

	fmt.Println(increases)
}
