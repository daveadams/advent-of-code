package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

type CPU struct {
	Instructions map[string]func([]string)
	Registers    map[string]uint64
	SP           uint64
	Memory       []string
}

func NewDualRegisterCPU() *CPU {
	cpu := &CPU{
		Instructions: map[string]func([]string){},
		Registers: map[string]uint64{
			"a": 1,
			"b": 0,
		},
		SP:     0,
		Memory: []string{},
	}

	cpu.Instructions["hlf"] = func(args []string) {
		if register, ok := cpu.Registers[args[0]]; ok {
			cpu.Registers[args[0]] = register / 2
			cpu.SP++
		} else {
			panic(fmt.Errorf("Invalid register '%s' at memory address %d", args[0], cpu.SP))
		}
	}

	cpu.Instructions["tpl"] = func(args []string) {
		if register, ok := cpu.Registers[args[0]]; ok {
			cpu.Registers[args[0]] = register * 3
			cpu.SP++
		} else {
			panic(fmt.Errorf("Invalid register '%s' at memory address %d", args[0], cpu.SP))
		}
	}

	cpu.Instructions["inc"] = func(args []string) {
		if _, ok := cpu.Registers[args[0]]; ok {
			cpu.Registers[args[0]]++
			cpu.SP++
		} else {
			panic(fmt.Errorf("Invalid register '%s' at memory address %d", args[0], cpu.SP))
		}
	}

	cpu.Instructions["jmp"] = func(args []string) {
		offset, err := strconv.ParseInt(args[0], 10, 64)
		if err != nil {
			panic(fmt.Errorf("Invalid offset '%s' at memory address %d", args[0], cpu.SP))
		}
		cpu.SP += uint64(offset)
	}

	cpu.Instructions["jie"] = func(args []string) {
		offset, err := strconv.ParseInt(args[1], 10, 64)
		if err != nil {
			panic(fmt.Errorf("Invalid offset '%s' at memory address %d", args[1], cpu.SP))
		}
		if _, ok := cpu.Registers[args[0]]; ok {
			if cpu.Registers[args[0]]%2 == 0 {
				cpu.SP += uint64(offset)
			} else {
				cpu.SP++
			}
		} else {
			panic(fmt.Errorf("Invalid register '%s' at memory address %d", args[0], cpu.SP))
		}
	}

	cpu.Instructions["jio"] = func(args []string) {
		offset, err := strconv.ParseInt(args[1], 10, 64)
		if err != nil {
			panic(fmt.Errorf("Invalid offset '%s' at memory address %d", args[1], cpu.SP))
		}
		if _, ok := cpu.Registers[args[0]]; ok {
			if cpu.Registers[args[0]] == 1 {
				cpu.SP += uint64(offset)
			} else {
				cpu.SP++
			}
		} else {
			panic(fmt.Errorf("Invalid register '%s' at memory address %d", args[0], cpu.SP))
		}
	}

	return cpu
}

func (c *CPU) Load(program []string) {
	c.Memory = program
	c.SP = 0
}

func Parse(memory string) (string, []string, error) {
	tokens := strings.Split(memory, " ")
	if len(tokens) < 2 || len(tokens) > 3 {
		return "", nil, fmt.Errorf("Unexpected token count: %d", len(tokens))
	}
	instruction := tokens[0]
	args := []string{}
	for _, token := range tokens[1:] {
		args = append(args, strings.Trim(token, ",+"))
	}
	return instruction, args, nil
}

func (c *CPU) Halt() {
	fmt.Printf("HALT\n")
	fmt.Printf(" SP: %d\n", c.SP)
	fmt.Printf(" Registers:\n")
	for name, value := range c.Registers {
		fmt.Printf("     %s: %d\n", name, value)
	}
}

func (c *CPU) Execute() {
	for {
		if c.SP > uint64(len(c.Memory)-1) {
			c.Halt()
			return
		}
		instructionName, args, err := Parse(c.Memory[c.SP])
		if err != nil {
			panic(fmt.Errorf("%s at memory location %d", err, c.SP))
		}
		instruction, ok := c.Instructions[instructionName]
		if !ok {
			panic(fmt.Errorf("Unknown CPU instruction '%s' at memory location ", instructionName, c.SP))
		}
		instruction(args)
	}
}

func main() {
	raw, _ := ioutil.ReadFile(os.Args[1])
	program := strings.Split(strings.TrimSpace(string(raw)), "\n")

	cpu := NewDualRegisterCPU()
	cpu.Load(program)
	cpu.Execute()
}
