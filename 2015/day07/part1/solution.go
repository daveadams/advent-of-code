package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	//"sort"
	"strconv"
	"strings"
)

var Debug = false

func debug(s string, a ...any) {
	if Debug {
		fmt.Fprintf(os.Stderr, "DEBUG: %s\n", fmt.Sprintf(s, a...))
	}
}

type NodeValueFunc func(*Node) (uint16, bool)

type Node struct {
	Name       string
	NodeType   string
	Value      uint16
	IsSet      bool
	MaxInputs  int
	MaxOutputs int
	Inputs     []*Node
	Outputs    []*Node
	Calculate  NodeValueFunc
}

func (n *Node) String() string {
	return fmt.Sprintf("%s %s", n.NodeType, n.Name)
}

func (n *Node) ValueString() string {
	if n.IsSet {
		return fmt.Sprintf("%d", n.Value)
	} else {
		return fmt.Sprintf("---")
	}
}

func (n *Node) Tick() {
	value, ok := n.Calculate(n)
	if ok {
		n.Value = value
		n.IsSet = true
	}
	debug("Tick: %s (%s)", n, n.ValueString())
	for _, output := range n.Outputs {
		output.Tick()
	}
}

func (n *Node) Tock() {
	value, ok := n.Calculate(n)
	if ok {
		n.Value = value
		n.IsSet = true
	}
}

var AllNodes []*Node = []*Node{}

func SignalCalc(self *Node) (uint16, bool) {
	return self.Value, true
}

var AllSignals []*Node = []*Node{}

func NewSignalFromString(raw string) *Node {
	signal64, err := strconv.ParseUint(raw, 10, 16)
	if err != nil {
		panic(err)
	}
	return NewSignal(uint16(signal64))
}

func NewSignal(value uint16) *Node {
	debug(fmt.Sprintf("Creating new signal '%d'", value))
	rv := &Node{
		Name:       fmt.Sprintf("%d", value),
		NodeType:   "SIGNAL",
		Value:      value,
		IsSet:      true,
		MaxInputs:  1,
		MaxOutputs: 1,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate:  SignalCalc,
	}
	AllNodes = append(AllNodes, rv)
	AllSignals = append(AllSignals, rv)
	return rv
}

func ClockTick() {
	debug("Sending global Tick")
	for _, signal := range AllSignals {
		signal.Tick()
	}
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

var WireStack map[string]*Node = map[string]*Node{}

func FindWire(name string) *Node {
	if w, ok := WireStack[name]; ok {
		return w
	}
	WireStack[name] = NewWire(name)
	return WireStack[name]
}

func NewWire(name string) *Node {
	debug("Creating new wire '%s'", name)
	rv := &Node{
		Name:       name,
		NodeType:   "WIRE",
		IsSet:      false,
		MaxInputs:  1,
		MaxOutputs: 0,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate:  WireCalc,
	}
	AllNodes = append(AllNodes, rv)
	return rv
}

func AndGateCalc(n *Node) (uint16, bool) {
	if len(n.Inputs) < 2 {
		return 0, false
	}

	if !n.Inputs[0].IsSet || !n.Inputs[1].IsSet {
		return 0, false
	}

	return (n.Inputs[0].Value & n.Inputs[1].Value), true
}

func NewAndGate(input1, input2 *Node) *Node {
	name := fmt.Sprintf("'%s'&'%s'", input1, input2)

	debug("Creating new ANDGATE")
	rv := &Node{
		Name:       name,
		NodeType:   "ANDGATE",
		IsSet:      false,
		MaxInputs:  2,
		MaxOutputs: 1,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate:  AndGateCalc,
	}

	if err := rv.AddInput(input1); err != nil {
		panic("Could not create AND gate: " + err.Error())
	}

	if err := rv.AddInput(input2); err != nil {
		panic("Could not create AND gate: " + err.Error())
	}

	AllNodes = append(AllNodes, rv)
	return rv
}

func OrGateCalc(n *Node) (uint16, bool) {
	if len(n.Inputs) < 2 {
		return 0, false
	}

	if !n.Inputs[0].IsSet || !n.Inputs[1].IsSet {
		return 0, false
	}

	return (n.Inputs[0].Value | n.Inputs[1].Value), true
}

func NewOrGate(input1, input2 *Node) *Node {
	name := fmt.Sprintf("'%s'|'%s'", input1, input2)

	debug("Creating new ORGATE")
	rv := &Node{
		Name:       name,
		NodeType:   "ORGATE",
		IsSet:      false,
		MaxInputs:  2,
		MaxOutputs: 1,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate:  OrGateCalc,
	}

	if err := rv.AddInput(input1); err != nil {
		panic("Could not create OR gate: " + err.Error())
	}

	if err := rv.AddInput(input2); err != nil {
		panic("Could not create OR gate: " + err.Error())
	}

	AllNodes = append(AllNodes, rv)
	return rv
}

func NotGateCalc(n *Node) (uint16, bool) {
	if len(n.Inputs) < 1 {
		return 0, false
	}

	if !n.Inputs[0].IsSet {
		return 0, false
	}

	return ^n.Inputs[0].Value, true
}

func NewNotGate(input *Node) *Node {
	name := fmt.Sprintf("^'%s'", input)

	debug("Creating new NOTGATE")
	rv := &Node{
		Name:       name,
		NodeType:   "NOTGATE",
		IsSet:      false,
		MaxInputs:  1,
		MaxOutputs: 1,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate:  NotGateCalc,
	}

	if err := rv.AddInput(input); err != nil {
		panic("Could not create NOT gate: " + err.Error())
	}

	AllNodes = append(AllNodes, rv)
	return rv
}

func NewRShiftGate(input *Node, shiftCount uint16) *Node {
	name := fmt.Sprintf("'%s'>>%d", input, shiftCount)

	debug("Creating new RSHIFT")
	rv := &Node{
		Name:       name,
		NodeType:   "RSHIFT",
		IsSet:      false,
		MaxInputs:  1,
		MaxOutputs: 1,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate: func(n *Node) (uint16, bool) {
			if len(n.Inputs) < 1 {
				return 0, false
			}

			if !n.Inputs[0].IsSet {
				return 0, false
			}

			return (n.Inputs[0].Value >> shiftCount), true
		},
	}

	if err := rv.AddInput(input); err != nil {
		panic("Could not create RSHIFT gate: " + err.Error())
	}

	AllNodes = append(AllNodes, rv)
	return rv
}

func NewLShiftGate(input *Node, shiftCount uint16) *Node {
	name := fmt.Sprintf("'%s'<<%d", input, shiftCount)

	debug("Creating new LSHIFT")
	rv := &Node{
		Name:       name,
		NodeType:   "LSHIFT",
		IsSet:      false,
		MaxInputs:  1,
		MaxOutputs: 1,
		Inputs:     []*Node{},
		Outputs:    []*Node{},
		Calculate: func(n *Node) (uint16, bool) {
			if len(n.Inputs) < 1 {
				return 0, false
			}

			if !n.Inputs[0].IsSet {
				return 0, false
			}

			return (n.Inputs[0].Value << shiftCount), true
		},
	}

	if err := rv.AddInput(input); err != nil {
		panic("Could not create LSHIFT gate: " + err.Error())
	}

	AllNodes = append(AllNodes, rv)
	return rv
}

func (n *Node) AddInput(input *Node) error {
	debug("Adding input to %s", n)
	for _, existingInput := range n.Inputs {
		if input == existingInput {
			debug("Input already attached to this node")
			return nil
		}
	}

	if len(n.Inputs) >= n.MaxInputs && n.MaxInputs != 0 {
		debug("FAILED: No more than %d inputs allowed per %s", n.MaxInputs, n.NodeType)
		return fmt.Errorf("Only %d inputs allowed per %s", n.MaxInputs, n.NodeType)
	}
	if input == nil {
		debug("FAILED: Doesn't make sense to add a nil input")
		return fmt.Errorf("Doesn't make sense to add a nil input")
	}

	n.Inputs = append(n.Inputs, input)
	if err := input.AddOutput(n); err != nil {
		debug("FAILED: Could not add output to input: %s", err)
		return fmt.Errorf("Could not add output to input: %s", err)
	}
	return nil
}

func (n *Node) AddOutput(output *Node) error {
	debug("Adding output to %s", n)
	for _, existingOutput := range n.Outputs {
		if output == existingOutput {
			debug("Output already attached to this node")
			return nil
		}
	}

	if len(n.Outputs) >= n.MaxOutputs && n.MaxOutputs != 0 {
		debug("FAILED: No more than %d outputs allowed per %s", n.MaxOutputs, n.NodeType)
		return fmt.Errorf("Only %d outputs allowed per %s", n.MaxOutputs, n.NodeType)
	}
	if output == nil {
		debug("FAILED: Doesn't make sense to add a nil output")
		return fmt.Errorf("Doesn't make sense to add a nil output")
	}

	n.Outputs = append(n.Outputs, output)
	if err := output.AddInput(n); err != nil {
		debug("FAILED: Could not add input to output: %s", err)
		return fmt.Errorf("Could not add input to output: %s", err)
	}
	return nil
}

var (
	WireOrSignalPattern = regexp.MustCompile(`^([0-9]+|[a-z]+)$`)
	SignalPattern       = regexp.MustCompile(`^[0-9]+$`)
	WirePattern         = regexp.MustCompile(`^[a-z]+$`)
	NotGatePattern      = regexp.MustCompile(`^NOT [a-z]+$`)
	AndOrGatePattern    = regexp.MustCompile(`^([a-z]+|[0-9]+) (AND|OR) ([a-z]+|[0-9]+)$`)
	ShiftGatePattern    = regexp.MustCompile(`^[a-z]+ [LR]SHIFT [0-9]+$`)
)

func ParseWireOrSignal(raw string) *Node {
	if SignalPattern.MatchString(raw) {
		return NewSignalFromString(raw)
	}

	if WirePattern.MatchString(raw) {
		return FindWire(raw)
	}

	panic("Unknown pattern '" + raw + "'")
}

func ParseInput(raw string) *Node {
	if WireOrSignalPattern.MatchString(raw) {
		return ParseWireOrSignal(raw)
	}

	if NotGatePattern.MatchString(raw) {
		token := strings.TrimPrefix(raw, "NOT ")
		return NewNotGate(ParseWireOrSignal(token))
	}

	if AndOrGatePattern.MatchString(raw) {
		tokens := strings.Split(raw, " ")
		if tokens[1] == "AND" {
			return NewAndGate(
				ParseWireOrSignal(tokens[0]),
				ParseWireOrSignal(tokens[2]),
			)
		} else if tokens[1] == "OR" {
			return NewOrGate(
				ParseWireOrSignal(tokens[0]),
				ParseWireOrSignal(tokens[2]),
			)
		}
	}

	if ShiftGatePattern.MatchString(raw) {
		tokens := strings.Split(raw, " ")
		var shiftCount uint16

		if shift64, err := strconv.ParseUint(tokens[2], 10, 16); err != nil {
			panic(err)
		} else {
			shiftCount = uint16(shift64)
		}

		if tokens[1] == "RSHIFT" {
			return NewRShiftGate(ParseWireOrSignal(tokens[0]), shiftCount)
		} else if tokens[1] == "LSHIFT" {
			return NewLShiftGate(ParseWireOrSignal(tokens[0]), shiftCount)
		}
	}

	panic("Unknown input pattern: '" + raw + "'")

	return nil
}

func ProcessLine(line string) {
	halves := strings.Split(line, " -> ")
	input := ParseInput(halves[0])
	output := FindWire(halves[1])
	output.AddInput(input)
}

func UnsetNodeCount() int {
	count := 0
	for _, node := range AllNodes {
		if !node.IsSet {
			count++
		}
	}
	return count
}

func TockAllNodes() {
	for _, node := range AllNodes {
		node.Tock()
	}
}

func main() {
	//Debug = true

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

	//fmt.Printf("BUILT %d signals, %d wires, and %d total nodes!\n", len(AllSignals), len(WireStack), len(AllNodes))

	//fmt.Printf("Total Unset Nodes: %d/%d\n", UnsetNodeCount(), len(AllNodes))
	for i := 0; UnsetNodeCount() > 0; i++ {
		TockAllNodes()
		//fmt.Printf("Total Unset Nodes: %d/%d\n", UnsetNodeCount(), len(AllNodes))
	}
	TockAllNodes()

	//ClockTick()

	//fmt.Printf("DEBUG RESULTS:\n")

	//wireNames := []string{}
	//for name := range WireStack {
	//	wireNames = append(wireNames, name)
	//}
	//sort.Strings(wireNames)

	//for _, name := range wireNames {
	//	fmt.Printf("%s: %s\n", WireStack[name], WireStack[name].ValueString())
	//}

	fmt.Printf("%d\n", FindWire("a").Value)
}
