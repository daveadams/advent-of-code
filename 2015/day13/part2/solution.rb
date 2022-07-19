#!/usr/bin/env ruby

guest_happiness = {}
guest_pairs = {}

ARGF.each_line do |line|
  if line =~ /^([A-Za-z]+) would (gain|lose) ([0-9]+) happiness units by sitting next to ([A-Za-z]+).$/
    sitter, direction, num, sittee = $1, $2, $3, $4
    multiplier = if direction == "lose"
                   -1
                 else
                   1
                 end
    value_change = num.to_i * multiplier

    guest_happiness[sitter] ||= 0
    guest_pairs[sitter] ||= {}
    guest_pairs[sitter][sittee] = value_change
  end
end

guest_names = guest_happiness.keys.sort

# part2: add self to the mix
guest_happiness["you"] = 0
guest_pairs["you"] = {}
guest_names.each do |guest|
  guest_pairs["you"][guest] = 0
  guest_pairs[guest]["you"] = 0
end
guest_names += ["you"]

happiest_permutation = []
happiest_total = 0

guest_names.permutation.each do |p|
  perm_happiness =
    p.each_cons(2).collect do |pair|
      g1, g2 = *pair
      guest_pairs[g1][g2] + guest_pairs[g2][g1]
    end.sum +
    guest_pairs[p.first][p.last] +
    guest_pairs[p.last][p.first]
  if perm_happiness > happiest_total
    happiest_total = perm_happiness
    happiest_permutation = p
  end
end

puts happiest_total
