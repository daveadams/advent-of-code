package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Node struct {
	Name string
	NodeType string
	Value uint16
	Inputs []Node
	Outputs []Node
}

func (n *Node) Tick() {
}

type Signal struct {
	Node
}

type NewSignalFromString(raw string) *Signal {
	signal64, err := strconv.ParseUint(raw, 10, 16)
	if err != nil {
		panic(err)
	}
	return NewSignal(uint16(signal64))
}

type NewSignal(value uint16) *Signal {
	return &Signal{
		Name: fmt.Sprintf("%d", value),
		NodeType: "SIGNAL",
		Value: value,
		Inputs: []Node{},
		Outputs: []Node{},
	}
}

func (n *Node) Send(value uint16) {
	for _, output := range n.Outputs {
		output.Send(value)
	}
}

func NewSignal(value uint16) *Node {
}



type Receiver interface{
	Send(uint16)
}

type Common struct {
	Value uint16
	IsSet bool
}

type Input struct {
	Common
	Parent *Gate
}

type GateFunc func([]Input) uint16

type Gate struct {
	Common
	Inputs []*Input
	Operation GateFunc
	Output Receiver
}

type Signal struct {
	Common
	Output Receiver
}

type Wire struct {
	Common
	Receivers []Node
}


var (
	WireOrSignalPattern = regexp.MustCompile(`^([0-9]+|[a-z]+)$`)
	SignalPattern       = regexp.MustCompile(`^[0-9]+$`)
	WirePattern         = regexp.MustCompile(`^[a-z]+$`)
	NotGatePattern      = regexp.MustCompile(`^NOT [a-z]+$`)
	AndOrGatePattern    = regexp.MustCompile(`^([a-z]+|[0-9]+) (AND|OR) ([a-z]+|[0-9]+)$`)
	ShiftGatePattern    = regexp.MustCompile(`^[a-z]+ [LR]SHIFT [0-9]+$`)
)

func NewSignal(signal string) {
	}
}

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
