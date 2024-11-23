packer {
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source = "github.com/hashicorp/amazon"
            }
        ansible = {
            version = ">= 1.0.0"
            source = "github.com/hashicorp/ansible"
            }
    }
}

variable "ami_prefix" {
    default = "wp-serv"
}

variable "region"{
    default = "eu-central-1"
    }

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

source "amazon-ebs" "wordpress" {
    region = var.region
    source_ami_filter {
        filters = {
            name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
            root-device-type = "ebs"
            virtualization-type = "hvm"
        }
        owners = ["099720109477"]
        most_recent = true
    }

    instance_type = var.instance_type # Исправлено
    ssh_username = var.ssh_username
    ami_name = "${var.ami_prefix} - ${uuidv4()}"
}

build {
    sources = ["source.amazon-ebs.wordpress"]

    provisioner "shell" {
        inline = [
            "sudo add-apt-repository universe -y",
            "sudo apt-get update -y",
            "sudo apt-get install -y  python3 python3-pip apache2 mysql-server php-mysql libapache2-mod-php",

            "sudo systemctl start apache2",
            "sudo systemctl enable --now apache2",
            "sudo systemctl start mysql",
            "sudo systemctl enable --now mysql",

            "wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz",
            "sudo mkdir -p /var/www/html/",
            "sudo chown -R $USER:$USER /var/www/html/",
            "sudo chmod -R 775 /var/www/html/",
            "tar xzvf /tmp/wordpress.tar.gz -C /var/www/html/",
            "sudo chown -R www-data:www-data /var/www/html/",
            "sudo chmod -R 755 /var/www/html/",

            ]
        }


    provisioner "ansible" {
        playbook_file = "../ansible/playbook.yml"
        extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
    }
}

// "sudo mysql -e \"CREATE DATABASE wordpress; CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'SDFLB*#JMV(#@@LKEGS)'; GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost'; FLUSH PRIVILEGES;\"",
//             "sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php",
//             "sudo sed -i 's/define(\\'DB_NAME\\', \\'database_name_here\\');/define(\\'DB_NAME\\', \\'wordpress\\');/' /var/www/html/wp-config.php",
//             "sudo sed -i 's/define(\\'DB_USER\\', \\'username_here\\');/define(\\'DB_USER\\', \\'wp_user\\');/' /var/www/html/wp-config.php",
//             "sudo sed -i 's/define(\\'DB_PASSWORD\\', \\'password_here\\');/define(\\'DB_PASSWORD\\', \\'SDFLB*#JMV(#@@LKEGS)\\');/' /var/www/html/wp-config.php"