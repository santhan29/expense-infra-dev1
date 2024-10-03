locals {
    vpc_id = data.aws_ssm_parameter.vpc_id.value 
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value) 
}