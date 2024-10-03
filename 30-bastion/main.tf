module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = data.aws_ami.joindevops.id 

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id] 
  subnet_id              = local.public_subnet_id 

  tags = merge(
    var.common_tags,
    var.bastion_tags,
    {
      Name = local.resource_name 
    }
  )
    
} 