module "sample" {
  source = "./solution"
  input  = file("../data/sample.txt")
}

module "actual" {
  source = "./solution"
  input  = file("../data/input.txt")
}

output "solution" {
  value = {
    part1 = {
      sample = module.sample.solution.part1
      actual = module.actual.solution.part1
    }
    part2 = {
      sample = module.sample.solution.part2
      actual = module.actual.solution.part2
    }
  }
}
