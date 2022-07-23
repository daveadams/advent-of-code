package main

import (
	"bufio"
	"crypto/md5"
	"fmt"
	"io"
	"os"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	for {
		// read a line at a time
		line, err := reader.ReadSlice('\n')
		if err == io.EOF {
			// exit gracefully if we hit the end of file
			os.Exit(0)
		}
		if err != nil {
			fmt.Fprintf(os.Stderr, "ERROR: %s\n", err)
			os.Exit(1)
		}
		// line includes the trailing \n, so slice it out
		fmt.Printf("%x\n", md5.Sum(line[:len(line)-1]))
	}
}
