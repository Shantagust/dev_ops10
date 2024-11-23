

variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

provider "aws" {
  region = "eu-central-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_instance" "web_server" {
  ami           = "ami-0b0c836a737ee51d7"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx

              echo "Hello from Nginx on Terraform!" > /var/www/html/index.html

              systemctl start nginx
              systemctl enable nginx
              EOF
  tags = {
    Name = "TerraformWebServer"
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
