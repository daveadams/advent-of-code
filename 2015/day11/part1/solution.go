package main

import (
	"fmt"
	"os"
	"regexp"
)

func ReverseString(s string) string {
	bytes := []byte(s)
	rvbytes := make([]byte, len(bytes))
	for i, j := len(bytes)-1, 0; i >= 0; i, j = i-1, j+1 {
		rvbytes[j] = bytes[i]
	}
	return string(rvbytes)
}

type Password struct {
	Bytes []byte
}

func NewPassword(pw string) *Password {
	return &Password{
		Bytes: []byte(ReverseString(pw)),
	}
}

func (pw *Password) String() string {
	return ReverseString(string(pw.Bytes))
}

func (pw *Password) IncrementDigit(digit int) {
	if digit > len(pw.Bytes) {
		pw.Bytes = append(pw.Bytes, 'a')
		return
	}

	pw.Bytes[digit]++
	if pw.Bytes[digit] > 'z' {
		pw.Bytes[digit] = 'a'
		pw.IncrementDigit(digit + 1)
	}

	// skip disallowed characters entirely
	if pw.Bytes[digit] == 'i' || pw.Bytes[digit] == 'l' || pw.Bytes[digit] == 'o' {
		pw.Bytes[digit]++
	}
}

func (pw *Password) Increment() {
	pw.IncrementDigit(0)
}

const (
	DoubleCharStr = `(aa|bb|cc|dd|ee|ff|gg|hh|jj|kk|mm|nn|pp|qq|rr|ss|tt|uu|vv|ww|xx|yy|zz)`
)

var (
	BadChars         = regexp.MustCompile(`[ilo]`)
	ThreeStraight    = regexp.MustCompile(`(abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)`)
	DoubleChar       = regexp.MustCompile(DoubleCharStr)
	DoubleDoubleChar = regexp.MustCompile(DoubleCharStr + `.*` + DoubleCharStr)
)

func (pw *Password) IsValid() bool {
	// convert current value to string once
	s := pw.String()

	if BadChars.MatchString(s) {
		return false
	}

	if !ThreeStraight.MatchString(s) {
		return false
	}

	matches := DoubleDoubleChar.FindAllStringSubmatch(s, -1)
	if matches == nil {
		return false
	}

	for _, matchSet := range matches {
		//fmt.Printf("Matchy %q\n", matchSet)
		if matchSet[1] != matchSet[2] {
			return true
		}
	}

	return false
}

func (pw *Password) FindNext() {
	for {
		pw.Increment()
		if pw.IsValid() {
			break
		}
	}
}

func main() {
	pw := NewPassword(os.Args[1])

	pw.FindNext()
	fmt.Printf("%s\n", pw)
}
