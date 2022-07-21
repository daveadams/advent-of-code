package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

type Sub struct {
	From string
	To   []string
}

var (
	SubKeys    = []string{}
	AllSubs    = map[string]*Sub{}
	SubMatcher *regexp.Regexp
)

func NewSub(from, to string) {
	if sub, ok := AllSubs[from]; !ok {
		SubKeys = append(SubKeys, from)
		AllSubs[from] = &Sub{
			From: from,
			To:   []string{to},
		}
	} else {
		sub.To = append(sub.To, to)
	}
}

// misinterpetation of part1
//func ProcessSubstitutions(base string) []string {
//	rv := []string{}
//	sub := AllSubs[SubMatcher.FindStringSubmatch(base)[1]]
//	rest := strings.TrimPrefix(sub.From, base)
//	done := rest == ""
//
//	if done {
//		for _, to := range sub.To {
//			rv = append(rv, to)
//		}
//	} else {
//		for _, tail := range ProcessSubstitutions(rest) {
//			for _, to := range sub.To {
//				rv = append(rv, to+tail)
//			}
//		}
//	}
//	return rv
//}

func main() {
	rawInput, _ := ioutil.ReadFile(os.Args[1])
	allLines := strings.Split(strings.TrimSpace(string(rawInput)), "\n")
	startingMolecule := allLines[len(allLines)-1]

	for _, line := range allLines {
		if line == "" {
			// we've reached the end of substitution definitions
			break
		}
		parts := strings.Split(line, " ")
		NewSub(parts[0], parts[2])
	}
	SubMatcher = regexp.MustCompile("^(" + strings.Join(SubKeys, "|") + ")")

	// break down string into substitutable tokens
	remaining := startingMolecule
	tokens := []string{}
	for {
		if remaining == "" {
			break
		}
		match := SubMatcher.FindStringSubmatch(remaining)
		var token string

		if match != nil {
			token = match[1]
		} else {
			token = remaining[0:1]
		}
		tokens = append(tokens, token)
		remaining = strings.TrimPrefix(remaining, token)
	}

	possibilities := map[string]bool{}
	for i, token := range tokens {
		sub, ok := AllSubs[token]
		if !ok {
			continue
		}

		for _, to := range sub.To {
			tokens[i] = to
			possibilities[strings.Join(tokens, "")] = true
		}
		// restore the original token
		tokens[i] = token
	}

	possibleMolecules := []string{}
	for pm := range possibilities {
		possibleMolecules = append(possibleMolecules, pm)
	}

	fmt.Println(len(possibleMolecules))

	//results := ProcessSubstitutions(startingMolecule)
	//for _, result := range results {
	//	fmt.Println(result)
	//}
}
