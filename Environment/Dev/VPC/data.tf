data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "expense_vpc" {
  default = true
} 

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.expense_vpc.id
  filter {
    name = "association.expense_vpc"
    values = ["true"]
  }
}