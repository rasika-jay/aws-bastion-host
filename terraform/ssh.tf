resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = var.ssh_key
}