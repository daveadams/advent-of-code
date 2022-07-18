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
	total_decoded_bytes := 0

	for _, line := range strings.Split(string(inbytes), "\n") {
		if strings.TrimSpace(line) == "" {
			continue
		}

		total_code_bytes += len(line)

		// drop beginning and ending quote marks
		trimmed := strings.TrimPrefix(strings.TrimSuffix(line, `"`), `"`)

		// traverse the trimmed string a character at a time, looking for backslashes,
		// and counting the size of the resulting decoded string
		decoded_bytes := 0
		decoded_string := ""
		for i := 0; i < len(trimmed); i++ {
			if trimmed[i] == '\\' {
				if trimmed[i+1] == '\\' {
					decoded_string += `\`
					decoded_bytes += 1
					i++
					continue
				}
				if trimmed[i+1] == '"' {
					decoded_string += `"`
					decoded_bytes += 1
					i++
					continue
				}
				if trimmed[i+1] == 'x' {
					decoded_string += "?"
					decoded_bytes += 1
					i += 3
					continue
				}
				fmt.Printf("ERROR: Got a sequence on '%s': %x%x%x (%q%q%q)\n", line, trimmed[i], trimmed[i+1], trimmed[i+2], trimmed[i], trimmed[i+1], trimmed[i+2])
				panic("Unexpected situation!")
			} else {
				decoded_string += string([]byte{trimmed[i]})
				decoded_bytes += 1
				continue
			}
		}
		//fmt.Printf("DECODED: '%s' to '%s'\n", line, decoded_string)
		total_decoded_bytes += decoded_bytes
	}

	final_answer := total_code_bytes - total_decoded_bytes
	//fmt.Printf("total code bytes: %d\ntotal decoded bytes: %d\n", total_code_bytes, total_decoded_bytes)
	fmt.Println(final_answer)
}
