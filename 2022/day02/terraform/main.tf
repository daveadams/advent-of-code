module "sample" {
  source = "./solution"
  input  = file("../data/sample.txt")
}

module "input" {
  source = "./solution"
  input  = file("../data/input.txt")
}

output "solution" {
  value = {
    part1 = {
      sample = module.sample.solution.part1
      input  = module.input.solution.part1
    }
    part2 = {
      sample = module.sample.solution.part2
      input  = module.input.solution.part2
    }
  }
}
