package main

import (
	"fmt"
	//	"io/ioutil"
	"os"
	//	"regexp"
	"strconv"
	//	"strings"
)

var Debug = false

func debug(s string) {
	if Debug {
		fmt.Fprintf(os.Stderr, "DEBUG: %s\n", s)
	}
}

type NodeValueFunc func(*Node) (uint16, bool)

type Node struct {
	Name      string
	NodeType  string
	Value     uint16
	IsSet     bool
	Inputs    []*Node
	Outputs   []*Node
	Calculate NodeValueFunc
}

func (n *Node) Tick() {
	debug(fmt.Sprintf("Tick: %s %s", n.NodeType, n.Name))
	value, ok := n.Calculate(n)
	if ok {
		n.Value = value
		n.IsSet = true
	}
	for _, output := range n.Outputs {
		output.Tick()
	}
}

type Signal struct {
	Node
}

func SignalCalc(self *Node) (uint16, bool) {
	return self.Value, true
}

var AllSignals []*Signal = []*Signal{}

func NewSignalFromString(raw string) *Signal {
	signal64, err := strconv.ParseUint(raw, 10, 16)
	if err != nil {
		panic(err)
	}
	return NewSignal(uint16(signal64))
}

func NewSignal(value uint16) *Signal {
	debug(fmt.Sprintf("Creating new signal '%d'", value))
	rv := &Signal{
		Node: Node{
			Name:      fmt.Sprintf("%d", value),
			NodeType:  "SIGNAL",
			Value:     value,
			IsSet:     true,
			Inputs:    []*Node{},
			Outputs:   []*Node{},
			Calculate: SignalCalc,
		},
	}
	AllSignals = append(AllSignals, rv)
	return rv
}

func ClockTick() {
	debug("Sending global Tick")
	for _, signal := range AllSignals {
		signal.Tick()
	}
}

type Wire struct {
	Node
}

func WireCalc(self *Node) (uint16, bool) {
	if len(self.Inputs) < 1 {
		return 0, false
	}

	if len(self.Inputs) > 1 {
		panic("Too many inputs! Wires can only have one input!")
	}

	if !self.Inputs[0].IsSet {
		return 0, false
	}

	return self.Inputs[0].Value, true
}

var WireStack map[string]*Wire = map[string]*Wire{}

func FindWire(name string) *Wire {
	if w, ok := WireStack[name]; ok {
		return w
	}
	WireStack[name] = NewWire(name)
	return WireStack[name]
}

func NewWire(name string) *Wire {
	debug(fmt.Sprintf("Creating new wire '%s'", name))
	return &Wire{
		Node: Node{
			Name:      name,
			NodeType:  "WIRE",
			IsSet:     false,
			Inputs:    []*Node{},
			Outputs:   []*Node{},
			Calculate: WireCalc,
		},
	}
}

func main() {
	Debug = true

	sig1 := NewSignal(200)
	sig2 := NewSignalFromString("1777")

	fmt.Printf("sig1: %s %s = %d\n", sig1.NodeType, sig1.Name, sig1.Value)
	fmt.Printf("sig2: %s %s = %d\n", sig2.NodeType, sig2.Name, sig2.Value)

	ClockTick()
}
