package main

import "fmt"

type Item struct {
	name   string
	cost   int
	damage int
	armor  int
}

func (i *Item) Name() string {
	if i == nil {
		return "<none>"
	}
	return i.name
}

func (i *Item) Cost() int {
	if i == nil {
		return 0
	}
	return i.cost
}

func (i *Item) Damage() int {
	if i == nil {
		return 0
	}
	return i.damage
}

func (i *Item) Armor() int {
	if i == nil {
		return 0
	}
	return i.armor
}

var (
	Weapons = []*Item{
		&Item{name: "Dagger", cost: 8, damage: 4, armor: 0},
		&Item{name: "Shortsword", cost: 10, damage: 5, armor: 0},
		&Item{name: "Warhammer", cost: 25, damage: 6, armor: 0},
		&Item{name: "Longsword", cost: 40, damage: 7, armor: 0},
		&Item{name: "Greataxe", cost: 74, damage: 8, armor: 0},
	}
	Armors = []*Item{
		nil,
		&Item{name: "Leather", cost: 13, damage: 0, armor: 1},
		&Item{name: "Chainmail", cost: 31, damage: 0, armor: 2},
		&Item{name: "Splintmail", cost: 53, damage: 0, armor: 3},
		&Item{name: "Bandedmail", cost: 75, damage: 0, armor: 4},
		&Item{name: "Platemail", cost: 102, damage: 0, armor: 5},
	}
	Rings = []*Item{
		nil,
		&Item{name: "Damage +1", cost: 25, damage: 1, armor: 0},
		&Item{name: "Damage +2", cost: 50, damage: 2, armor: 0},
		&Item{name: "Damage +3", cost: 100, damage: 3, armor: 0},
		&Item{name: "Defense +1", cost: 20, damage: 0, armor: 1},
		&Item{name: "Defense +2", cost: 40, damage: 0, armor: 2},
		&Item{name: "Defense +3", cost: 80, damage: 0, armor: 3},
	}
)

type Loadout struct {
	Weapon *Item
	Armor  *Item
	Ring1  *Item
	Ring2  *Item
}

func (l *Loadout) Cost() int {
	return l.Weapon.Cost() + l.Armor.Cost() + l.Ring1.Cost() + l.Ring2.Cost()
}

func (l *Loadout) Defense() int {
	return l.Weapon.Armor() + l.Armor.Armor() + l.Ring1.Armor() + l.Ring2.Armor()
}

func (l *Loadout) Damage() int {
	return l.Weapon.Damage() + l.Armor.Damage() + l.Ring1.Damage() + l.Ring2.Damage()
}

type Entity struct {
	HP      int
	Damage  int
	Defense int
}

func (e *Entity) Attack(enemy *Entity) {
	damage := e.Damage - enemy.Defense
	if damage < 1 {
		damage = 1
	}
	enemy.HP -= damage
}

func (e *Entity) IsDead() bool {
	return e.HP <= 0
}

func (l *Loadout) CanWin() bool {
	// simulate the fight
	hero := &Entity{
		HP:      100,
		Damage:  l.Damage(),
		Defense: l.Defense(),
	}
	boss := &Entity{
		HP:      100,
		Damage:  8,
		Defense: 2,
	}

	for {
		hero.Attack(boss)
		if boss.IsDead() {
			return true
		}
		boss.Attack(hero)
		if hero.IsDead() {
			return false
		}
	}
}

func main() {
	loadouts := []*Loadout{}

	// build loadouts
	for _, weapon := range Weapons {
		for _, armor := range Armors {
			for _, ring1 := range Rings {
				for _, ring2 := range Rings {
					if ring1 == ring2 && ring1 != nil {
						// can't wear two of the same ring
						continue
					}
					loadouts = append(
						loadouts,
						&Loadout{
							Weapon: weapon,
							Armor:  armor,
							Ring1:  ring1,
							Ring2:  ring2,
						},
					)
				}
			}
		}
	}
	fmt.Printf("Built %d loadouts!\n", len(loadouts))

	winningLoadouts := []*Loadout{}
	losingLoadouts := []*Loadout{}
	var cheapestWinner *Loadout
	var priciestLoser *Loadout
	for _, loadout := range loadouts {
		if loadout.CanWin() {
			if cheapestWinner == nil || cheapestWinner.Cost() > loadout.Cost() {
				cheapestWinner = loadout
			}
			winningLoadouts = append(winningLoadouts, loadout)
		} else {
			if priciestLoser == nil || priciestLoser.Cost() < loadout.Cost() {
				priciestLoser = loadout
			}
			losingLoadouts = append(losingLoadouts, loadout)
		}
	}
	fmt.Println()
	fmt.Printf("%d loadouts can win!\n", len(winningLoadouts))
	fmt.Printf("Cheapest winner costs %d gold!\n", cheapestWinner.Cost())
	fmt.Printf("  Weapon: %s\n", cheapestWinner.Weapon.Name())
	fmt.Printf("   Armor: %s\n", cheapestWinner.Armor.Name())
	fmt.Printf("  Ring 1: %s\n", cheapestWinner.Ring1.Name())
	fmt.Printf("  Ring 2: %s\n", cheapestWinner.Ring2.Name())
	fmt.Println()
	fmt.Printf("%d loadouts will lose!\n", len(losingLoadouts))
	fmt.Printf("Priciest loser costs %d gold!\n", priciestLoser.Cost())
	fmt.Printf("  Weapon: %s\n", priciestLoser.Weapon.Name())
	fmt.Printf("   Armor: %s\n", priciestLoser.Armor.Name())
	fmt.Printf("  Ring 1: %s\n", priciestLoser.Ring1.Name())
	fmt.Printf("  Ring 2: %s\n", priciestLoser.Ring2.Name())
}
