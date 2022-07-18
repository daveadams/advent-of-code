package main

import (
	"crypto/md5"
	"fmt"
	"os"
	"strings"
)

const (
	MiningDifficulty = 6
	AllZeros         = "00000000000000000000000000000000"
)

var (
	GoodPrefix = AllZeros[:MiningDifficulty]
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <key>\n", os.Args[0])
		os.Exit(1)
	}
	key := os.Args[1]
	for n := 1; ; n++ {
		if tryMining(key, n) {
			fmt.Printf("%d\n", n)
			os.Exit(0)
		}
		//	if n%10000 == 0 {
		//		fmt.Printf("Processing hash number %d...\n", n)
		//	}
	}
}

func tryMining(key string, i int) bool {
	bytesToHash := []byte(fmt.Sprintf("%s%d", key, i))
	sumHexStr := fmt.Sprintf("%x", md5.Sum(bytesToHash))
	return strings.HasPrefix(sumHexStr, GoodPrefix)
}
