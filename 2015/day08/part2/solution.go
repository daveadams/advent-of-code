package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <filename>\n", os.Args[0])
		os.Exit(1)
	}

	inbytes, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: Could not read '%s': %s\n", os.Args[1], err)
		os.Exit(1)
	}

	total_code_bytes := 0
	total_encoded_bytes := 0

	for _, line := range strings.Split(string(inbytes), "\n") {
		if strings.TrimSpace(line) == "" {
			continue
		}

		total_code_bytes += len(line)

		// traverse the string a character at a time, looking for characters to
		// escape and counting the size of the resulting encoded string
		// start with 2 for the beginning and end quotes
		encoded_bytes := 2
		for i := 0; i < len(line); i++ {
			if line[i] == '\\' {
				encoded_bytes += 2
			} else if line[i] == '"' {
				encoded_bytes += 2
			} else {
				encoded_bytes += 1
			}
		}
		//fmt.Printf("DECODED: '%s' to '%s'\n", line, decoded_string)
		total_encoded_bytes += encoded_bytes
	}

	final_answer := total_encoded_bytes - total_code_bytes
	//fmt.Printf("total code bytes: %d\ntotal decoded bytes: %d\n", total_code_bytes, total_decoded_bytes)
	fmt.Println(final_answer)
}
