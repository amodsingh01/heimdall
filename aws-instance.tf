resource "aws_instance" "Heimdall-kali" {
  subnet_id     = aws_subnet.Heimdalldata-public-subnet-1.id
  instance_type = var.instance_type
  ami           = "ami-0eb546bea6ed49174"
  key_name      = aws_key_pair.Heimdall-key.key_name

  vpc_security_group_ids = [aws_security_group.Heimdall-Public-SG.id]
  tags = {
    Name = "Heimdall-Kali-${random_pet.server.id}-${random_id.server.dec}"
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "kali"
    private_key = file("./id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config",
      "echo 'HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config",
      "sudo systemctl restart sshd"
    ]
  }

}
resource "aws_instance" "Heimdall-Guacamole" {
  subnet_id              = aws_subnet.Heimdalldata-public-subnet-1.id
  instance_type          = var.instance_type
  ami                    = "ami-0fc5d935ebf8bc3bc"
  key_name               = aws_key_pair.Heimdall-key.key_name
  vpc_security_group_ids = [aws_security_group.Heimdall-Public-SG.id]

  tags = {
    Name = "Heimdall-Guacamole-${random_pet.server.id}-${random_id.server.dec}"
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./id_rsa")
  }
  provisioner "file" {
    source      = "./scripts_and_files/"
    destination = "/home/ubuntu"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo tar -xzvf backup.tar.gz",
      "sudo mkdir /etc/certs",
      "sudo mv archive/ live/ renewal/ renewal-hooks /etc/certs/",
      "chmod +x ./guacamole.sh",
      "./guacamole.sh heimdall-guacamole-${lower("${random_pet.server.id}-${random_id.server.dec}")}.kikrr.cloud",
      "wget https://git.io/fxZq5 -O guac-install.sh",
      "sudo chmod +x guac-install.sh",
      "sudo ./guac-install.sh --mysqlpwd password --guacpwd password --nomfa --installmysql",
      "sleep 20",
    ]
  }
}

resource "aws_instance" "Heimdall-test-app" {
  subnet_id              = aws_subnet.Heimdalldata-public-subnet-1.id
  instance_type          = var.instance_type
  ami                    = "ami-0fc5d935ebf8bc3bc"
  key_name               = aws_key_pair.Heimdall-key.key_name
  vpc_security_group_ids = [aws_security_group.Heimdall-Public-SG.id]

  tags = {
    Name = "Heimdall-test-app-${random_pet.server.id}-${random_id.server.dec}"
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./id_rsa")
  }
  provisioner "file" {
    source      = "./scripts_and_files/"
    destination = "/home/ubuntu"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo tar -xzvf backup.tar.gz",
      "sudo mkdir /etc/certs",
      "sudo mv archive/ live/ renewal/ renewal-hooks /etc/certs/",
      "chmod +x ./nopcommerce.sh",
      "./nopcommerce.sh heimdall-test-app-${lower("${random_pet.server.id}-${random_id.server.dec}")}.kikrr.cloud",
      "sleep 20"
    ]
  }
}

resource "aws_instance" "Heimdall-proxy-server" {
  subnet_id              = aws_subnet.Heimdalldata-public-subnet-1.id
  instance_type          = "t2.medium"
  ami                    = "ami-0fc5d935ebf8bc3bc"
  key_name               = aws_key_pair.Heimdall-key.key_name
  iam_instance_profile   = aws_iam_instance_profile.Heimdall-EC2-role.id
  vpc_security_group_ids = [aws_security_group.Heimdall-Public-SG.id]
  tags = {
    Name = "Heimdall_proxy_&_manager-${random_pet.server.id}-${random_id.server.dec}"
  }
  root_block_device {
    volume_size = "20"
    volume_type = "gp3"
  }
  connection {
    host        = self.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = file("./id_rsa")
  }
  provisioner "file" {
    source      = "./scripts_and_files/"
    destination = "/home/ubuntu"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'bash <(curl -s http://s3.heimdalldata.com/hdinstall.sh) server'",
      "sudo systemctl start heimdall && sudo systemctl enable heimdall",
      "sudo tar -xzvf backup.tar.gz",
      "sudo mkdir /etc/certs",
      "sudo mv archive/ live/ renewal/ renewal-hooks /etc/certs/",
      "chmod +x ./heimdall.sh",
      "./heimdall.sh heimdall-proxy-manager-${lower("${random_pet.server.id}-${random_id.server.dec}")}.kikrr.cloud",
      "sleep 20",
      "echo 'PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config",
      "echo 'HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config",
      "sudo systemctl restart sshd"
    ]
  }
}

# variable "ssh_key" {
#   type = string
#   default = file("./id_rsa")
  
# }

resource "null_resource" "Guacamole_connections" {

  connection {
    host        = aws_instance.Heimdall-Guacamole.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./id_rsa")
  }
# provisioner "file" {
#   source      = "./scripts_and_files/"
#   destination = "/home/ubuntu"

# }
provisioner "remote-exec" {


  inline  = [
    "sleep 20",
    "chmod +x add_connection.sh",
    "./add_connection.sh http://localhost:8080 Kali-machine ${aws_instance.Heimdall-kali.public_ip} kali \"${replace(file("./id_rsa"), "\n", "\\n")}\"",
    "sleep 5",
    "./add_connection.sh http://localhost:8080 Heimdall_proxy_manager ${aws_instance.Heimdall-proxy-server.public_ip} ubuntu \"${replace(file("./id_rsa"), "\n", "\\n")}\"",
    "sleep 5",
    "./add_connection.sh http://localhost:8080 Test_App ${aws_instance.Heimdall-test-app.public_ip} ubuntu \"${replace(file("./id_rsa"), "\n", "\\n")}\"",
    "sleep 5"
    ]

}

  depends_on = [ 
    aws_route53_record.Heimdall_guacamole,
    aws_route53_record.Heimdall_proxy_manger,
    aws_route53_record.Heimdall_test_app,
    aws_instance.Heimdall-kali 
    ]

}