package main

import (
	"crypto/md5"
	"fmt"
	"os"
)

const MiningDifficulty = 5

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
	sumBytes := md5.Sum(bytesToHash)
	if sumBytes[0] == 0 && sumBytes[1] == 0 && sumBytes[2] <= 9 {
		//fmt.Printf("GOOD HASH: %x\n", sumBytes)
		return true
	} else {
		//fmt.Printf("BAD HASH: %x\n", sumBytes)
		return false
	}
}
