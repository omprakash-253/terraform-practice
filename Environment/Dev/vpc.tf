resource "aws_vpc" "expense_vpc" {
    cidr_block = "10.10.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"

    tags = {
        Name = "${var.project}-vpc"
        project = "${var.project}"
        Module = "vpc"
        Maintainer = "terraform"
    }
}

resource "aws_subnet" "expense_public_subnet" {
    count = length(var.public_subnet_cidr)
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
    cidr_block = var.public_subnet_cidr[count.index]
    vpc_id = aws_vpc.expense_vpc.id
    
    tags = merge(var.common_tags, {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
        
    })
}

resource "aws_subnet" "expense_private_subnet" {
    count = length(var.private_subnet_cidr)
    availability_zone = local.az_names[count.index]
    cidr_block = var.private_subnet_cidr[count.index]
    vpc_id = aws_vpc.expense_vpc.id
    
    tags = merge(var.common_tags, {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        
    })
}

resource "aws_subnet" "expense_db_subnet" {
    count = length(var.db_subnet_cidr)
    availability_zone = local.az_names[count.index]
    cidr_block = var.db_subnet_cidr[count.index]
    vpc_id = aws_vpc.expense_vpc.id
    
    tags = merge(var.common_tags, {
        Name = "${local.resource_name}-db-${local.az_names[count.index]}"
        
    })
}