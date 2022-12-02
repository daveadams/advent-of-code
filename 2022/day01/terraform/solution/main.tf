variable "input" {
  type = string
}

locals {
  batches      = [for raw_batch in split("\n\n", var.input) : trimspace(raw_batch)]
  batch_totals = [for batch in local.batches : sum([for snack in split("\n", batch) : tonumber(snack)])]

  # hack to sort numerically
  longest_length  = reverse(sort([for t in local.batch_totals : length(tostring(t))]))[0]
  sortable_totals = formatlist("%0${local.longest_length}d", local.batch_totals)
  sorted_totals   = [for s in sort(local.sortable_totals) : tonumber(s)]

  top  = reverse(local.sorted_totals)[0]
  top3 = sum(slice(reverse(local.sorted_totals), 0, 3))
}

output "solution" {
  value = {
    part1 = local.top
    part2 = local.top3
  }
}
