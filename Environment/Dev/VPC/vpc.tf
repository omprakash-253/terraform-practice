resource "aws_vpc" "expense_vpc" {
    cidr_block = var.vpc_cidr
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


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.e.id

  tags = merge(
    var.common_tags,
       {
        Name = local.resource_name
    }
  )
}


resource "aws_security_group" "allow_tls" {
  name        = local.sg_name_final
  description = var.sg_description
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
        from_port       = ingress.value["from_port"]
        to_port         = ingress.value["to_port"]
        protocol        = ingress.value["protocol"]
        cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  dynamic "egress" {
    for_each = var.outbound_rules
    content {
        from_port       = egress.value["from_port"]
        to_port         = egress.value["to_port"]
        protocol        = egress.value["protocol"]
        cidr_blocks = egress.value["cidr_blocks"]
    }
  }

  tags = merge(
    var.common_tags,
    var.sg_tags,
    {
        Name = local.sg_name_final
    }
  )
}


resource "aws_subnet" "expense_public_subnet" {
    count = length(var.public_subnet_cidr)
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = false
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
    map_public_ip_on_launch = false
    
    tags = merge(var.common_tags, {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        
    })
}

resource "aws_subnet" "expense_db_subnet" {
    count = length(var.db_subnet_cidr)
    availability_zone = local.az_names[count.index]
    cidr_block = var.db_subnet_cidr[count.index]
    vpc_id = aws_vpc.expense_vpc.id
    map_public_ip_on_launch = false
    
    tags = merge(var.common_tags, {
        Name = "${local.resource_name}-db-${local.az_names[count.index]}"
        
    })
}


resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.expense_db_subnet[*].id

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.expense_public_subnet[0].id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}" #expense-dev
    }
  )
    # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw] # this is explicit dependency
}

## Public Route table ##

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.expense_vpc.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.resource_name}-public" #expense-dev-public
    }
  )
}

#### Private Route table ####
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.expense_vpc.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.resource_name}-private" #expense-dev-private
    }
  )
}

#### Database Route table ####
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.expense_vpc.id

  tags = merge(
    var.common_tags,
    var.db_route_table_tags,
    {
        Name = "${local.resource_name}-database" #expense-dev-database
    }
  )
}


#### Routes ####
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route_nat" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database_route_nat" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#### Route table and subnet associations ####
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.expense_public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.expense_private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.db_subnet_cidr)
  subnet_id      = element(aws_subnet.expense_db_subnet[*].id, count.index)
  route_table_id = aws_route_table.database.id
}