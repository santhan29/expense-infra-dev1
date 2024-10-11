variable "zone_name" {
    default = "aws81s.store" 
}

variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev" 
}

variable "common_tags" {
    default = {
        Project = "expense"
        Terraform = "true"
        Environment = "dev"
    }
} 

variable "zone_id" {
    default = "Z01291701B7D72LVWRG1U"
}