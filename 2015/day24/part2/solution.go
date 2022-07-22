package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
	//"time"
)

func power(base, exponent int) int {
	rv := 1
	for n := 0; n < exponent; n++ {
		rv = rv * base
	}
	return rv
}

func main() {
	raw, _ := ioutil.ReadFile(os.Args[1])
	weights := []int{}
	totalWeight := 0
	for _, s := range strings.Split(strings.TrimSpace(string(raw)), "\n") {
		i, _ := strconv.Atoi(s)
		totalWeight += i
		weights = append(weights, i)
	}
	targetWeight := totalWeight / 4
	fmt.Printf(" TOTAL WEIGHT: %d\nTARGET WEIGHT: %d\n", totalWeight, targetWeight)
	fmt.Printf("\nPOSSIBLE COMBOS: %d\n", power(2, len(weights)))

	weight := 0
	validCombos := [][]int{}
	//startTime := time.Now()
TopLoop:
	for i := 0; i < power(2, len(weights)); i++ {
		weight = 0
		for b := 0; b < len(weights); b++ {
			if (i>>b)&1 == 1 {
				weight += weights[b]
				if weight > targetWeight {
					continue TopLoop
				}
			}
		}
		if weight != targetWeight {
			continue TopLoop
		}

		combo := []int{}
		for b := 0; b < len(weights); b++ {
			if (i>>b)&1 == 1 {
				combo = append(combo, weights[b])
			}
		}
		validCombos = append(validCombos, combo)
	}
	fmt.Printf("   VALID COMBOS: %d\n\n", len(validCombos))

	fewest := 1000000
	minCombos := [][]int{}
	// find the valid combos with the fewest packages
	for _, combo := range validCombos {
		if len(combo) < fewest {
			minCombos = [][]int{}
			fewest = len(combo)
		}
		if len(combo) == fewest {
			minCombos = append(minCombos, combo)
		}
	}
	fmt.Printf("FEWEST PACKAGES: %d\n", fewest)
	fmt.Printf(" MINIMAL COMBOS: %d\n", len(minCombos))

	minQE := -1
	var qeCombo []int
	for _, combo := range minCombos {
		qe := 1
		for _, i := range combo {
			qe = qe * i
		}
		if minQE == -1 || qe < minQE {
			minQE = qe
			qeCombo = combo
		}
	}

	fmt.Printf("\nMINIMUM QUANTUM ENTANGLEMENT: %d\n\n", minQE)
	fmt.Printf("%#v\n", qeCombo)

	// generate combinations that match targetWeight

	//	bucket := 0
	//	solutions := []*Solution{}
	//	solTotals := make([]int, NUM_BUCKETS)
	//	fmt.Printf("Total loops: %d\n", power(NUM_BUCKETS, len(weights)))
	//	startTime := time.Now()
	//	for n := 0; n < power(NUM_BUCKETS, len(weights)); n++ {
	//		if n%100000000 == 0 {
	//			fmt.Printf("(%s) %dM %d\n", time.Since(startTime).Truncate(time.Millisecond), n/1000000, len(solutions))
	//		}
	//		sol := NewSolution()
	//		for b := 0; b < NUM_BUCKETS; b++ {
	//			solTotals[b] = 0
	//		}
	//		for i := 0; i < len(weights); i++ {
	//			bucket = (n / power(NUM_BUCKETS, i)) % NUM_BUCKETS
	//			solTotals[bucket] += weights[i]
	//			if solTotals[bucket] > targetWeight {
	//				return
	//			}
	//			sol.Buckets[bucket] = append(sol.Buckets[bucket], weights[i])
	//		}
	//	}

	//	fmt.Printf("Found %d solutions\n", len(solutions))
}
