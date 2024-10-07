module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
    
  name = local.resource_name
  ami = data.aws_ami.joindevops.id 

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id] 
  subnet_id              = local.private_subnet_id 

  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
      Name = local.resource_name 
    }
  )
    
}  

resource "null_resource" "backend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.backend.id  
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.backend.private_ip 
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321" 
  }

   provisioner "file" {    #copies code in backend.sh to /tmp/backend.sh 
    source      = "${var.backend_tags.Component}.sh" 
    destination = "/tmp/backend.sh" 
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh", 
      "sudo sh /tmp/backend.sh ${var.backend_tags.Component} ${var.environment}" 
    ]
  }

}

resource "aws_ec2_instance_state" "backend" {
    instance_id = module.backend.id 
    state = "stopped" 
    depends_on = [null_resource.backend] 
}

resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = module.backend.id 
  depends_on = [aws_ec2_instance_state.backend]  
}



resource "null_resource" "backend_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.backend.id  
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}" 
  }

  depends_on = [aws_ami_from_instance.backend] 

}