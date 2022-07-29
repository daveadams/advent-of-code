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

	aim := 0
	hpos := 0
	depth := 0

	for _, line := range strings.Split(strings.TrimSpace(string(raw)), "\n") {
		parts := strings.SplitN(line, " ", 2)
		command := parts[0]
		distance, _ := strconv.Atoi(parts[1])

		switch command {
		case "forward":
			hpos += distance
			depth += (distance * aim)
		case "up":
			aim -= distance
		case "down":
			aim += distance
		}
	}

	fmt.Println(hpos * depth)
}
