module "web_alb" {
  source = "terraform-aws-modules/alb/aws" 

  internal = false 
  name    = "${var.project_name}-${var.environment}-web-alb"  
  vpc_id  = local.vpc_id 
  subnets = local.public_subnet_id 
  security_groups = [data.aws_ssm_parameter.web_alb_sg_id.value] 
  create_security_group = false 
  enable_deletion_protection = false 

  tags = merge(
    var.common_tags,
    var.web_alb_tags

  ) 
}

resource "aws_lb_listener" "http" { 
  load_balancer_arn = module.web_alb.arn 
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type    = "text/html"
      message_body  = "<h1> hello, i am from web ALB<h1>"
      status_code = "200" 
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "expense-${var.environment}"  #expense-dev 
      type    = "A" 
      alias   = {
        name = module.web_alb.dns_name 
        zone_id = module.web_alb.zone_id 
      } 
      allow_overwrite = true 
    } 
  ]

}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.web_alb.arn 
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn 

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type    = "text/html"
      message_body  = "<h1> hello, i am from web ALB HTTPS<h1>"
      status_code = "200" 
    }
  }
  
}