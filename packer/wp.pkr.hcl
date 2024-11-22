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
            name = "ubuntu/images/hvm-ssd/ubuntu-22.04-minimal-*"
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
      # Обновление пакетов
      "sudo apt update -y",
      "sudo apt upgrade -y",

      # Установка Apache, MySQL, PHP и нужных модулей
      "sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php",

      # Запуск и включение сервисов
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "sudo systemctl start mysql",
      "sudo systemctl enable mysql",

      # Установка WordPress
      "wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz",
      "tar xzvf /tmp/wordpress.tar.gz -C /var/www/html/",
      "sudo chown -R www-data:www-data /var/www/html/",
      "sudo chmod -R 755 /var/www/html/",

      # Настройка базы данных
      "sudo mysql -e \"CREATE DATABASE wordpress; CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'your_password'; GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost'; FLUSH PRIVILEGES;\"",

      # Настройка конфигурации WordPress
      "sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php",
      "sudo sed -i 's/define(\\'DB_NAME\\', \\'database_name_here\\');/define(\\'DB_NAME\\', \\'wordpress\\');/' /var/www/html/wp-config.php",
      "sudo sed -i 's/define(\\'DB_USER\\', \\'username_here\\');/define(\\'DB_USER\\', \\'wp_user\\');/' /var/www/html/wp-config.php",
      "sudo sed -i 's/define(\\'DB_PASSWORD\\', \\'password_here\\');/define(\\'DB_PASSWORD\\', \\'your_password\\');/' /var/www/html/wp-config.php"
    ]
  }
}