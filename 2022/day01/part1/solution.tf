variable "infile" {
  type    = string
  default = "./input"
}

locals {
  input = file(var.infile)

  batches      = [for raw_batch in split("\n\n", local.input) : trimspace(raw_batch)]
  batch_totals = [for batch in local.batches : sum([for snack in split("\n", batch) : tonumber(snack)])]

  # hack to sort numerically
  longest_length  = reverse(sort([for t in local.batch_totals : length(tostring(t))]))[0]
  sortable_totals = formatlist("%0${local.longest_length}d", local.batch_totals)
  sorted_totals   = [for s in sort(local.sortable_totals) : tonumber(s)]

  top = reverse(local.sorted_totals)[0]
}

output "solution" {
  value = local.top
}
