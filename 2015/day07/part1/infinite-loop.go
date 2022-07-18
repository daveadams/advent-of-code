package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Node interface {
	Output() uint16
	Trace() []Node
}

type Wire struct {
	Name  string
	Input Node
}

func (w Wire) Output() uint16 {
	fmt.Printf("WIRE %s OUTPUT\n", w.Name)
	return w.Input.Output()
}

func (w Wire) Trace() []Node {
	return []Node{w.Input}
}

var WireStack map[string]*Wire = map[string]*Wire{}

func FindWire(name string) *Wire {
	if w, ok := WireStack[name]; ok {
		return w
	}
	WireStack[name] = &Wire{Name: name}
	return WireStack[name]
}

type Signal struct {
	Value uint16
}

func (s Signal) Output() uint16 {
	return s.Value
}

func (s Signal) Trace() []Node {
	return []Node{}
}

func NewSignal(value uint16) Node {
	return &Signal{
		Value: value,
	}
}

type AndGate struct {
	Input1 Node
	Input2 Node
}

func (g AndGate) Output() uint16 {
	return g.Input1.Output() & g.Input2.Output()
}

func (g AndGate) Trace() []Node {
	return []Node{g.Input1, g.Input2}
}

type OrGate struct {
	Input1 Node
	Input2 Node
}

func (g OrGate) Output() uint16 {
	return g.Input1.Output() | g.Input2.Output()
}

func (g OrGate) Trace() []Node {
	return []Node{g.Input1, g.Input2}
}

type NotGate struct {
	Input Node
}

func (g NotGate) Output() uint16 {
	return ^g.Input.Output()
}

func (g NotGate) Trace() []Node {
	return []Node{g.Input}
}

type RShiftGate struct {
	Input Node
	Count uint16
}

func (g RShiftGate) Output() uint16 {
	return g.Input.Output() >> g.Count
}

func (g RShiftGate) Trace() []Node {
	return []Node{g.Input}
}

type LShiftGate struct {
	Input Node
	Count uint16
}

func (g LShiftGate) Output() uint16 {
	return g.Input.Output() << g.Count
}

func (g LShiftGate) Trace() []Node {
	return []Node{g.Input}
}

var (
	WireOrSignalPattern = regexp.MustCompile(`^([0-9]+|[a-z]+)$`)
	SignalPattern       = regexp.MustCompile(`^[0-9]+$`)
	WirePattern         = regexp.MustCompile(`^[a-z]+$`)
	NotGatePattern      = regexp.MustCompile(`^NOT [a-z]+$`)
	AndOrGatePattern    = regexp.MustCompile(`^([a-z]+|[0-9]+) (AND|OR) ([a-z]+|[0-9]+)$`)
	ShiftGatePattern    = regexp.MustCompile(`^[a-z]+ [LR]SHIFT [0-9]+$`)
)

func ParseWireOrSignal(inputRaw string) Node {
	if SignalPattern.MatchString(inputRaw) {
		if signal64, err := strconv.ParseUint(inputRaw, 10, 16); err != nil {
			panic(err)
		} else {
			return NewSignal(uint16(signal64))
		}
	}

	if WirePattern.MatchString(inputRaw) {
		return FindWire(inputRaw)
	}

	panic("Unknown pattern '" + inputRaw + "'")
}

func ParseInput(inputRaw string) Node {
	if WireOrSignalPattern.MatchString(inputRaw) {
		return ParseWireOrSignal(inputRaw)
	}

	if NotGatePattern.MatchString(inputRaw) {
		wireName := strings.TrimPrefix(inputRaw, "NOT ")
		return &NotGate{
			Input: FindWire(wireName),
		}
	}

	if AndOrGatePattern.MatchString(inputRaw) {
		tokens := strings.Split(inputRaw, " ")
		if tokens[1] == "AND" {
			return &AndGate{
				Input1: ParseWireOrSignal(tokens[0]),
				Input2: ParseWireOrSignal(tokens[2]),
			}
		} else if tokens[1] == "OR" {
			return &OrGate{
				Input1: ParseWireOrSignal(tokens[0]),
				Input2: ParseWireOrSignal(tokens[2]),
			}
		}
	}

	if ShiftGatePattern.MatchString(inputRaw) {
		tokens := strings.Split(inputRaw, " ")
		var shiftCount uint16

		if shift64, err := strconv.ParseUint(tokens[2], 10, 16); err != nil {
			panic(err)
		} else {
			shiftCount = uint16(shift64)
		}

		if tokens[1] == "RSHIFT" {
			return &RShiftGate{
				Input: FindWire(tokens[0]),
				Count: shiftCount,
			}
		} else if tokens[1] == "LSHIFT" {
			return &LShiftGate{
				Input: FindWire(tokens[0]),
				Count: shiftCount,
			}
		}
	}

	panic("Unknown input pattern: '" + inputRaw + "'")

	return nil
}

func ProcessLine(line string) {
	halves := strings.Split(line, " -> ")
	//fmt.Printf("GOT LINE! '%s'\n  LSIDE: '%s'\n  RSIDE: '%s'\n", line, halves[0], halves[1])
	input := ParseInput(halves[0])
	//fmt.Printf("  INPUT: %#v\n", input)
	output := FindWire(halves[1])
	output.Input = input
	//fmt.Printf("  OUTPUT: %#v\n", output)
	//fmt.Printf("\n")
}

//var VisitedWires map[string]bool = map[string]bool{}
//
//func RunTrace(n Node) {
//	inputs := n.Trace()
//	if len(inputs) == 0 {

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

	for _, line := range strings.Split(string(inbytes), "\n") {
		if strings.TrimSpace(line) == "" {
			continue
		}
		ProcessLine(line)
	}

	//fmt.Printf("DEBUG RESULTS:\n")
	//for name, wire := range WireStack {
	//	fmt.Printf("%s: %d\n", name, wire.Output())
	//}
	fmt.Printf("%d\n", FindWire("a").Output())
	//a := FindWire("a")
	//RunTrace(a)
}
