locals {
    az_names = slice(data.aws_availability_zones.available.names, 0, 2)
    resource_name = "${var.project}-${var.environment}"
    sg_name_final = "${var.project_name}-${var.environment}-${var.sg_name}"
}
