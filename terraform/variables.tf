variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
  type        = string
}

variable "ami_name" {
  description = "Name of the AMI to search for"
  default     = "al2023-bastion"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.nano"
  type        = string
}

variable "allowed_cidrs" {
  description = "Allowed list of IP CIDRs"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "desired_num_instances" {
  description = "Number of bastion instances in autoscaling group"
  default     = 1
  type        = number
}

variable "ssh_key" {
  description = "Public SSH key - must be provided (i.e. cat ~/.ssh/id_rsa.pub or create new)"
  type        = string
}

variable "ssh_port" {
  description = "TCP port used for SSH"
  default     = 22
  type        = number
}