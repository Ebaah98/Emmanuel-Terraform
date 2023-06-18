provider "aws" {
  region  = "us-east-1"
  profile = "ebaah"
}

# Create default VPC if one does not exist
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# Use data source to get all availability zones in the region
data "aws_availability_zones" "available_zones" {}

# Create default subnet if one does not exist
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# Create security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http proxy access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins server security group"
  }
}

# Use data source to get a registered Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Launch the EC2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "MYEC2"

  tags = {
    Name = "emmanuel_jenkins"
  }
}

# Copy the install_jenkins.sh file from your computer to the EC2 instance 
resource "null_resource" "name" {
  # SSH into the EC2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/Downloads/MYEC2.pem")
    host        = aws_instance.ec2_instance.public_ip
  }

  # Copy the install_jenkins.sh file from your computer to the EC2 instance 
  provisioner "file" {
    source      = "/Users/emmanuelbaah/Documents/GitHub/Emmanuel-Terraform/ec2.sh"
    destination = "/tmp/ec2.sh"
  }

  # Set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/ec2.sh",
      "sh /tmp/ec2.sh"
    ]
  }

  # Wait for EC2 instance to be created
  depends_on = [aws_instance.ec2_instance]
}

# Print the URL of the Jenkins server
output "website_url" {
  value = join("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
}

# Create S3 bucket for Jenkins
resource "aws_s3_bucket" "baahemmanueljenkins" {
  bucket = "baahemmanueljenkins"
  
  # Set bucket ACL to private
  acl = "private"
}
provider "aws" {
  region  = "us-east-1"
  profile = "ebaah"
}

# Create default VPC if one does not exist
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# Use data source to get all availability zones in the region
data "aws_availability_zones" "available_zones" {}

# Create default subnet if one does not exist
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# Create security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http proxy access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins server security group"
  }
}

# Use data source to get a registered Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Launch the EC2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "MYEC2"

  tags = {
    Name = "emmanuel_jenkins"
  }
}

# Copy the install_jenkins.sh file from your computer to the EC2 instance 
resource "null_resource" "name" {
  # SSH into the EC2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/Downloads/MYEC2.pem")
    host        = aws_instance.ec2_instance.public_ip
  }

  # Copy the install_jenkins.sh file from your computer to the EC2 instance 
  provisioner "file" {
    source      = "/Users/emmanuelbaah/Documents/GitHub/Emmanuel-Terraform/ec2.sh"
    destination = "/tmp/ec2.sh"
  }

  # Set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/ec2.sh",
      "sh /tmp/ec2.sh"
    ]
  }

  # Wait for EC2 instance to be created
  depends_on = [aws_instance.ec2_instance]
}

# Print the URL of the Jenkins server
output "website_url" {
  value = join("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
}

# Create S3 bucket for Jenkins
resource "aws_s3_bucket" "baahemmanueljenkins" {
  bucket = "baahemmanueljenkins"
  
  # Set bucket ACL to private
  acl = "private"
}