provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0daf65a18bb5ab7a8" # Replace with your AMI ID
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
