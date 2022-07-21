package main

import (
	"crypto/md5"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"sort"
	"strings"
	"time"
)

var (
	AllSubs    = map[string][]string{}
	RevSubs    = map[string]string{}
	RevTokens  = []string{}
	RevPattern *regexp.Regexp
)

func NewSub(from, to string) {
	if _, ok := AllSubs[from]; !ok {
		AllSubs[from] = []string{}
	}
	AllSubs[from] = append(AllSubs[from], to)

	// ASSUMPTION (ok for actual input, dangerous for general case):
	// All substitution endpoints are unique.
	RevSubs[to] = from
	RevTokens = append(RevTokens, to)
}

type StringLengthReverseSorter struct {
	strings []string
}

func (s *StringLengthReverseSorter) Len() int {
	return len(s.strings)
}

func (s *StringLengthReverseSorter) Swap(i, j int) {
	s.strings[i], s.strings[j] = s.strings[j], s.strings[i]
}

func (s *StringLengthReverseSorter) Less(i, j int) bool {
	return len(s.strings[i]) > len(s.strings[j])
}

func ReverseSortStringsByLength(strings []string) {
	slrs := &StringLengthReverseSorter{strings: strings}
	sort.Sort(slrs)
}

type IndexPairReverseSorter struct {
	pairs [][]int
}

func (iprs *IndexPairReverseSorter) Len() int {
	return len(iprs.pairs)
}

func (iprs *IndexPairReverseSorter) Swap(i, j int) {
	iprs.pairs[i], iprs.pairs[j] = iprs.pairs[j], iprs.pairs[i]
}

func (iprs *IndexPairReverseSorter) Less(i, j int) bool {
	return (iprs.pairs[i][1] - iprs.pairs[i][0]) > (iprs.pairs[j][1] - iprs.pairs[j][0])
}

func ReverseSortIndexPairsByDistance(pairs [][]int) {
	iprs := &IndexPairReverseSorter{pairs: pairs}
	sort.Sort(iprs)
}

var (
	fastestSequence = -1
	possibilities   = 0
)

func ReverseEngineer(steps int, sequence, current, goal string) {
	if current == goal {
		if fastestSequence == -1 || fastestSequence > steps {
			fastestSequence = steps
		}
		fmt.Printf("Found a solution in %d steps!\n", steps)
		possibilities++
		return
	}
	matches := RevPattern.FindAllStringIndex(current, -1)
	if matches == nil {
		//fmt.Printf("Failed after %d steps!\n%s\n", steps, sequence)
		fmt.Printf("%x Failed after %d steps! %s\n", md5.Sum([]byte(sequence)), steps, current)
		possibilities++
		return
	}

	//ReverseSortIndexPairsByDistance(matches)
	//longestMatch := len(matches[0][1] - matches[0][0])

	for _, match := range matches {
		start := match[0]
		end := match[1]
		matched := current[start:end]
		prefix := ""
		suffix := ""
		if start > 0 {
			prefix = current[0:start]
		}
		if end < len(current) {
			suffix = current[end:len(current)]
		}
		//fmt.Printf("PREFIX: '%s'\nMATCHED: '%s'\nSUFFIX: '%s'\n", prefix, matched, suffix)
		//fmt.Printf("%d: Replacing '%s' with '%s' ('%s' => '%s')\n", steps+1, matched, RevSubs[matched], current, prefix+RevSubs[matched]+suffix)
		ReverseEngineer(steps+1, sequence+fmt.Sprintf(";%s => %s", matched, RevSubs[matched]), prefix+RevSubs[matched]+suffix, goal)
	}
	//fmt.Printf("matched: '%s' (%d:%d) (%d)\n", matched, start, end, end-start)
	//fmt.Printf("prefix: '%s'\nsuffix: '%s'\n", prefix, suffix)
	//if prefix+matched+suffix == current {
	//	fmt.Println("SEEMS TO BE COOL DUDE")
	//} else {
	//	fmt.Println("OH NOES")
	//}
	//return true, steps + 1
}

func main() {
	rawInput, _ := ioutil.ReadFile(os.Args[1])
	allLines := strings.Split(strings.TrimSpace(string(rawInput)), "\n")
	targetMolecule := allLines[len(allLines)-1]
	startingMolecule := "e"

	fmt.Println(targetMolecule)

	for _, line := range allLines {
		if line == "" {
			// we've reached the end of substitution definitions
			break
		}
		parts := strings.Split(line, " ")
		NewSub(parts[0], parts[2])
	}

	ReverseSortStringsByLength(RevTokens)
	fmt.Println("(" + strings.Join(RevTokens, "|") + ")")
	RevPattern = regexp.MustCompile("(" + strings.Join(RevTokens, "|") + ")")

	//if RevPattern.MatchString(targetMolecule) {
	//	fmt.Println("IT'S A MATCH")
	//} else {
	//	fmt.Println("WTFFFF")
	//}

	//ReverseEngineer(0, "", targetMolecule, startingMolecule)
	//if fastestSequence == -1 {
	//	fmt.Printf("FAILED TO FIND ANY SOLUTION AMONG %d POSSIBILITES!!\n", possibilities)
	//} else {
	//	fmt.Printf("SHORTEST SOLUTION AMONG %d POSSIBILITIES: %d STEPS\n", possibilities, fastestSequence)
	//}

	startTime := time.Now()
	possibilities := []string{targetMolecule}
	for step := 0; ; step++ {
		fmt.Printf("Search Depth %d; %d possibilities; ", step, len(possibilities))
		next := []string{}
		matchesAttempted := 0
		for _, poss := range possibilities {
			if poss == startingMolecule {
				fmt.Printf("\nFOUND IT AT: ")
				fmt.Println(step)
				os.Exit(0)
			}

			matches := RevPattern.FindAllStringIndex(poss, -1)
			if matches == nil {
				// no need to go further
				continue
			}

			for _, match := range matches {
				matchesAttempted++
				start := match[0]
				end := match[1]
				matched := poss[start:end]
				prefix := ""
				suffix := ""
				if start > 0 {
					prefix = poss[0:start]
				}
				if end < len(poss) {
					suffix = poss[end:len(poss)]
				}
				next = append(next, prefix+RevSubs[matched]+suffix)
			}
		}
		possibilities = next
		fmt.Printf("%d matches; ", matchesAttempted)
		fmt.Println(time.Since(startTime).Truncate(time.Second))
		startTime = time.Now()
	}
}
