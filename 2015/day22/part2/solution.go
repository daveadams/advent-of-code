package main

import (
	"fmt"
	"os"
)

var Debug = false

func debug(s string, a ...any) {
	if Debug {
		fmt.Fprintf(os.Stderr, "DEBUG: %s\n", fmt.Sprintf(s, a...))
	}
}

const (
	BossHP     = 58
	BossDamage = 9
	PlayerHP   = 50
	PlayerMana = 500
)

type Player struct {
	HP   int
	Mana int
}

func NewPlayer() *Player {
	return &Player{
		HP:   PlayerHP,
		Mana: PlayerMana,
	}
}

func (p *Player) CanCast(s *Spell) bool {
	return p.Mana >= s.Cost
}

func (p *Player) IsDead() bool {
	return p.HP <= 0
}

func (p *Player) IsOutOfMana() bool {
	// smallest spell cost
	return p.Mana < 53
}

type Spell struct {
	Name   string
	Cost   int
	Damage int
	Heal   int
	Effect func() *Effect
}

var (
	EmergencyMagicMissleSpell = Spell{
		Name:   "Emergency Magic Missile",
		Cost:   53,
		Damage: 4,
	}
	MagicMissleSpell = Spell{
		Name:   "Magic Missile",
		Cost:   53,
		Damage: 4,
	}
	DrainSpell = Spell{
		Name:   "Drain",
		Cost:   73,
		Damage: 2,
		Heal:   2,
	}
	ShieldSpell = Spell{
		Name: "Shield",
		Cost: 113,
		Effect: func() *Effect {
			return &Effect{
				Name:        "Shield",
				Duration:    6,
				ArmorChange: 7,
			}
		},
	}
	PoisonSpell = Spell{
		Name: "Poison",
		Cost: 173,
		Effect: func() *Effect {
			return &Effect{
				Name:       "Poison",
				Duration:   6,
				BossDamage: 3,
			}
		},
	}
	RechargeSpell = Spell{
		Name: "Recharge",
		Cost: 229,
		Effect: func() *Effect {
			return &Effect{
				Name:       "Recharge",
				Duration:   5,
				ManaChange: 101,
			}
		},
	}
)

type Effect struct {
	Name        string
	Duration    int
	ManaChange  int
	BossDamage  int
	ArmorChange int
}

type Boss struct {
	HP     int
	Damage int
}

func NewBoss() *Boss {
	return &Boss{
		HP:     BossHP,
		Damage: BossDamage,
	}
}

func (b *Boss) IsDead() bool {
	return b.HP <= 0
}

type Game struct {
	Player        *Player
	Boss          *Boss
	Effects       []*Effect
	SpellSequence []*Spell
	Turn          int
	IsOver        bool
	ManaSpent     int
	IsErrored     bool
}

func NewGame(spellSequence []*Spell) *Game {
	return &Game{
		Player:        NewPlayer(),
		Boss:          NewBoss(),
		Effects:       []*Effect{},
		SpellSequence: spellSequence,
	}
}

func (g *Game) CleanEffects() {
	newEffects := []*Effect{}
	for _, effect := range g.Effects {
		if effect.Duration > 0 {
			newEffects = append(newEffects, effect)
		} else {
			debug("%s has expired!\n", effect.Name)
		}
	}
	g.Effects = newEffects
}

func (g *Game) IsBossTurn() bool {
	return g.Turn%2 == 0
}

func (g *Game) IsPlayerTurn() bool {
	return !g.IsBossTurn()
}

func (g *Game) CalculatePlayerArmor() int {
	rv := 0
	for _, effect := range g.Effects {
		rv += effect.ArmorChange
	}
	return rv
}

func (g *Game) ProcessEffects() {
	for _, effect := range g.Effects {
		effect.Duration--
		if effect.ManaChange > 0 {
			g.Player.Mana += effect.ManaChange
			debug("%s provides %d mana to Player. Its timer is now %d.\n", effect.Name, effect.ManaChange, effect.Duration)
		}
		if effect.BossDamage > 0 {
			g.Boss.HP -= effect.BossDamage
			debug("%s deals %d damage to Boss. Its timer is now %d.\n", effect.Name, effect.BossDamage, effect.Duration)
		}
		if effect.ArmorChange > 0 {
			debug("%s provides %d bonus armor to Player. Its timer is now %d.\n", effect.Name, effect.ArmorChange, effect.Duration)
		}
	}
	g.CleanEffects()
}

func (g *Game) TurnAction() {
	if g.IsBossTurn() {
		g.BossAction()
	} else {
		g.PlayerAction()
	}
}

func (g *Game) PlayerAction() {
	if len(g.SpellSequence) == 0 {
		g.Player.HP = 0
		debug("ERROR: No more spells?! Player's hit points go to zero!\n")
		g.IsErrored = true
		return
	}
	var spell *Spell
	spell, g.SpellSequence = g.SpellSequence[0], g.SpellSequence[1:]
	if !g.Player.CanCast(spell) {
		debug("Player tries to cast %s, but doesn't have enough mana!\n", spell.Name)
		spell = &EmergencyMagicMissleSpell
	}

	g.Player.Mana -= spell.Cost
	g.ManaSpent += spell.Cost
	debug("Player casts %s!\n", spell.Name)
	if spell.Damage > 0 {
		g.Boss.HP -= spell.Damage
		debug("%s does %d damage to Boss.\n", spell.Name, spell.Damage)
	}
	if spell.Heal > 0 {
		g.Player.HP += spell.Heal
		debug("%s heals player for %d hit points.\n", spell.Name, spell.Heal)
	}
	if spell.Effect != nil {
		ok := true
		newEffect := spell.Effect()
		for _, activeEffect := range g.Effects {
			if newEffect.Name == activeEffect.Name {
				debug("Effect %s is already active! Nothing happens. Mana wasted!!\n", newEffect.Name)
				ok = false
				break
			}
		}
		if ok {
			g.Effects = append(g.Effects, newEffect)
		}
	}
}

func (g *Game) BossAction() {
	playerArmor := g.CalculatePlayerArmor()
	if playerArmor == 0 {
		g.Player.HP -= g.Boss.Damage
		debug("Boss attacks for %d damage.\n", g.Boss.Damage)
	} else {
		actualDamage := g.Boss.Damage - playerArmor
		if actualDamage < 1 {
			actualDamage = 1
		}
		g.Player.HP -= actualDamage
		debug("Boss attacks for %d - %d = %d damage.\n", g.Boss.Damage, playerArmor, actualDamage)
	}
}

func (g *Game) CheckStatus() {
	g.IsOver = g.Player.IsDead() || g.Player.IsOutOfMana() || g.Boss.IsDead()
}

func (g *Game) IsWin() bool {
	return g.IsOver && g.Boss.IsDead()
}

func (g *Game) PrintTurnHeader() {
	if g.IsBossTurn() {
		debug("-- Boss turn --\n")
	} else {
		debug("-- Player turn --\n")
	}
	playerArmor := g.CalculatePlayerArmor()
	debug("- Player has %d hit points, %d armor, %d mana\n", g.Player.HP, playerArmor, g.Player.Mana)
	debug("- Boss has %d hit points\n", g.Boss.HP)
}

func (g *Game) HardMode() {
	g.Player.HP--
	debug("HARD MODE: Player receives 1 damage!\n")
}

func (g *Game) NextTurn() {
	if g.IsOver {
		return
	}
	g.Turn++
	g.PrintTurnHeader()
	g.HardMode()
	g.CheckStatus()
	if g.IsOver {
		return
	}
	g.ProcessEffects()
	g.CheckStatus()
	if g.IsOver {
		return
	}
	g.TurnAction()
	g.CheckStatus()
}

func (g *Game) Play() {
	for !g.IsOver {
		g.NextTurn()
	}
	if g.Boss.IsDead() {
		debug("GAME OVER! The Boss is dead! Player wins!\n")
	} else if g.Player.IsDead() {
		debug("GAME OVER! Player is dead! The Boss wins!\n")
	} else if g.Player.IsOutOfMana() {
		debug("GAME OVER! Player is out of mana! The Boss wins!\n")
	} else {
		debug("GAME OVER?! NOT SURE WHY!\n")
		g.IsErrored = true
	}
}

type SpellBook struct {
	Spells []*Spell
}

func NewSpellBook() *SpellBook {
	return &SpellBook{
		Spells: []*Spell{
			&MagicMissleSpell,
			&DrainSpell,
			&ShieldSpell,
			&PoisonSpell,
			&RechargeSpell,
		},
	}
}

func CopySlice[T any](from []T) []T {
	rv := []T{}
	for _, item := range from {
		rv = append(rv, item)
	}
	return rv
}

func (sb *SpellBook) GenerateSpellSequences(turns int) [][]*Spell {
	last := [][]*Spell{
		[]*Spell{},
	}
	next := [][]*Spell{}
	for i := 0; i < turns; i++ {
		for _, list := range last {
			for _, spell := range sb.Spells {
				listCopy := CopySlice[*Spell](list)
				listCopy = append(listCopy, spell)
				next = append(next, listCopy)
			}
		}
		last = next
		next = [][]*Spell{}
	}
	return last
}

func main() {
	sb := NewSpellBook()
	fmt.Printf("Generating spell sequences... ")
	seqs := sb.GenerateSpellSequences(11)
	fmt.Printf("OK\n")

	count := 0
	results := make([]*Game, 0, len(seqs))
	wins := 0
	losses := 0
	errors := 0
	neededMoreSpells := 0
	minimumMana := 1000000

	fmt.Printf("Running games..")
	for _, seq := range seqs {
		count++
		game := NewGame(seq)
		game.Play()
		if game.IsWin() {
			wins++
			if game.ManaSpent < minimumMana {
				minimumMana = game.ManaSpent
			}
			debug("WIN! Mana spent: %d\n", game.ManaSpent)
		} else {
			losses++
			debug("Loss!\n")
		}
		if game.IsErrored {
			if len(game.SpellSequence) == 0 {
				neededMoreSpells++
			}
			errors++
		}
		results = append(results, game)
		if count%100000 == 0 {
			fmt.Printf(".")
		}
	}
	fmt.Printf(" OK\n\n")

	fmt.Printf("Total Games Played: %d\n\n  Wins: %d\nLosses: %d\nErrors: %d\n", count, wins, losses, errors)
	if neededMoreSpells > 0 {
		fmt.Printf("  %d games needed more spells!\n", neededMoreSpells)
	}
	fmt.Printf("\nMinimum Mana: %d\n", minimumMana)
}
