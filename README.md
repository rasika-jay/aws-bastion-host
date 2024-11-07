# Assumptions

1. VPC, Subnets, IG, NAT, ACL and Routing tables are already created.
2. Your AWS account follows AWS Well-Architected best practices and have Public and Private subnets.
3. No code for above is included as per instructions.
4. Docker is used for Packer/Terraform instead of native install dependencies - feel free to update the `PACKER_BIN` / `TERRAFORM_BIN` vars in the Makefile to suit your environment or use native commands.
5. **VPC** is tagged with `Name:main`, Single **private** subnet with `Type:private` and Single **public** subnet with `Type:public`

# Implimentation Decisions

1. I have used Docker (instead of native install) to isolate my build environment and to always be consistent. I also didn't want to install build dependancies locally. I have created a simple `Makefile` to run these Docker commands, but it is not neccasary and native commands will work as normal.
2. I have used `us-east-1` as the AWS region as my personal AWS account is locked to this region.
3. I have disabled SSH Password authentication for added security.
4. I have created linting/syntax checking for Packer, Ansible and Terraform which are automatically executed in the Make targets.
5. I have used the Goss provisioner for Packer from https://github.com/YaleUniversity/packer-plugin-goss
6. The Docker image used is based on the official Packer image, which I've added Ansible. See `Dockerfile` in the `docker/packer-ansible` folder.

# Requirements

1. Docker (if you use the Makefile) **OR** [Packer, Ansible & Terraform]
2. AWS credentials configured with sufficient permissions in your local environment

# Where is everything?

1. Packer files are in `packer` folder
2. Ansible playbook is in `packer/provisioners/ansible` folder
3. Goss files are in `packer/provisioners/goss` folder
4. Terraform files are in `terraform` folder
5. Custom Dockerfile, which is based on the Official Packer image is in `docker/packer-ansible` folder

# Quick start

1. Run `make packer-build` to create AMI in your AWS account first.
2. Run `make terraform-plan` to see a TF plan OR `make terraform-apply` to create a Bastion Host. Terraform will output the DNS endpoint at the end of provisioning.
3. RUN `make terraform-destroy` to destroy the Bastion Host.

SSH username is the default `ec2-user` for amazon-linux.

## NOTE: Terraform will prompt for a public SSH key

# Security considerations

1. Ensure bastion hosts are provisioned in locked-down private subnets, protected from the internet
2. Use an IP whitelist
3. Don't use a Bastion Host - use AWS Session Manager or AWS Cloud Shell instead
4. Consider using something like `checkov` for scanning Terraform code
5. Rotate SSH keys frequently
6. Enable MFA for SSH

# Bonus questions
1. CloudWatch Alarm - please see `cloudwatch.tf`
2. You can configure this bastion as an SSH jump host, but ideally consider AWS Cloud Shell, AWS Session Manager or a VPN

# Todo
1. Validation for Input variables
2. Individual SSH keys for users in Ansible
3. Generate keys automatically and store in SecretsManager
