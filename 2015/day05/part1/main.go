package main

import (
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"
)

var (
	ThreeVowels   = regexp.MustCompile("[aeiou].*[aeiou].*[aeiou]")
	DoubleLetters = regexp.MustCompile("(aa|bb|cc|dd|ee|ff|gg|hh|ii|jj|kk|ll|mm|nn|oo|pp|qq|rr|ss|tt|uu|vv|ww|xx|yy|zz)")
	BadMatches    = regexp.MustCompile("(ab|cd|pq|xy)")
)

func IsNice(word string) bool {
	return ThreeVowels.MatchString(word) && DoubleLetters.MatchString(word) && !BadMatches.MatchString(word)
}

func main() {
	niceCount := 0
	naughtyCount := 0

	bytes, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: Couldn't read STDIN because: %s", err)
		os.Exit(1)
	}

	for _, line := range strings.Split(string(bytes), "\n") {
		word := strings.TrimSpace(line)
		//fmt.Printf("DEBUG: GOT WORD '%s'\n", word)
		if word == "" {
			continue
		}
		if IsNice(word) {
			niceCount++
		} else {
			naughtyCount++
		}
	}

	fmt.Printf("%d\n", niceCount)
}
