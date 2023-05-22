resource "aws_subnet" "subnet" {
  for_each          = var.subnet_cidr
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = var.subnet_az[each.key]

  tags = {
    Name = each.key
  }
}
