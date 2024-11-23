provider "aws" {
  region = "eu-central-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_instance" "web_server" {
  ami           = "ami-0daf65a18bb5ab7a8"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /var/www/html/index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "TerraformWebServer"
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
