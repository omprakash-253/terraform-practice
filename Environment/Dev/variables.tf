variable "project" {
  description = "Project name"
  type        = string
  default     = "expense"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Maintainer  = "terraform"
    Project     = "expense"
    Environment = "dev"
  }
}


variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}


variable "public_subnet_cidrs" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "db_subnet_cidrs" {
  default = ["10.10.21.0/24", "10.10.22.0/24"]
}

# variable "public_subnet_cidr" {
#   description = "CIDR block for the public subnet"
#   type        = string
#   validation {
#     condition     = var.public_subnet_cidr == 2
#     error_message = "Please provide the valid CIDR block for the public subnet must be 2."
#   }
# }

# variable "private_subnet_cidr" {
#   description = "CIDR block for the private subnet"
#   type        = string
#   validation {
#     condition     = var.private_subnet_cidr == 2
#     error_message = "Please provide the valid CIDR block for the private subnet must be 2."
#   }
# }

# variable "db_subnet_cidr" {
#   description = "CIDR block for the database subnet"
#   type        = string
#   validation {
#     condition     = var.db_subnet_cidr == 2
#     error_message = "Please provide the valid CIDR block for the database subnet must be 2."
#   }
# }
