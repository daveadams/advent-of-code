variable "input" {
  type = string
}

locals {
  opponent_move_lookup = {
    A = "rock"
    B = "paper"
    C = "scissors"
  }

  part1_move_lookup = {
    X = "rock"
    Y = "paper"
    Z = "scissors"
  }

  part2_outcome_lookup = {
    X = "lose"
    Y = "draw"
    Z = "win"
  }

  move_score_lookup = {
    rock     = 1
    paper    = 2
    scissors = 3
  }

  outcome_score_lookup = {
    lose = 0
    draw = 3
    win  = 6
  }

  outcome_move_lookup = {
    rock = {
      lose = "scissors"
      draw = "rock"
      win  = "paper"
    }
    paper = {
      lose = "rock"
      draw = "paper"
      win  = "scissors"
    }
    scissors = {
      lose = "paper"
      draw = "scissors"
      win  = "rock"
    }
  }

  outcome_lookup = {
    rock = {
      rock     = "draw"
      paper    = "win"
      scissors = "lose"
    }
    paper = {
      rock     = "lose"
      paper    = "draw"
      scissors = "win"
    }
    scissors = {
      rock     = "win"
      paper    = "lose"
      scissors = "draw"
    }
  }

  raw_pairs = [for line in split("\n", trimspace(var.input)) : split(" ", line)]

  part1_moves = [for pair in local.raw_pairs : {
    opponent_move = local.opponent_move_lookup[pair[0]]
    my_move       = local.part1_move_lookup[pair[1]]
  }]

  part2_moves = [for pair in local.raw_pairs : {
    opponent_move = local.opponent_move_lookup[pair[0]]
    my_move       = local.outcome_move_lookup[local.opponent_move_lookup[pair[0]]][local.part2_outcome_lookup[pair[1]]]
  }]

  part1_outcomes = [for moves in local.part1_moves : {
    my_move = moves.my_move
    outcome = local.outcome_lookup[moves.opponent_move][moves.my_move]
  }]

  part2_outcomes = [for moves in local.part2_moves : {
    my_move = moves.my_move
    outcome = local.outcome_lookup[moves.opponent_move][moves.my_move]
  }]

  part1_scores = [for outcomes in local.part1_outcomes : local.move_score_lookup[outcomes.my_move] + local.outcome_score_lookup[outcomes.outcome]]
  part2_scores = [for outcomes in local.part2_outcomes : local.move_score_lookup[outcomes.my_move] + local.outcome_score_lookup[outcomes.outcome]]
}

output "solution" {
  value = {
    part1 = sum(local.part1_scores)
    part2 = sum(local.part2_scores)
  }
}
