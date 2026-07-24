// EC2 Instance "OpenVPN"
resource "aws_instance" "openvpn" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.sg_openvpn.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "openvpn"
  }
}

// EC2 Instance "Nginx-proxy1"
resource "aws_instance" "nginxproxy1" {
  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg_others.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "nginxproxy1"
  }
}

// EC2 Instance "Nginx-proxy2"
resource "aws_instance" "nginxproxy2" {
  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet3.id
  vpc_security_group_ids = [aws_security_group.sg_others.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "nginxproxy2"
  }
}

// EC2 Instance "Nginx-web1"
resource "aws_instance" "nginxweb1" {
  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg_others.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "nginxweb1"
  }
}

// EC2 Instance "Nginx-web2"
resource "aws_instance" "nginxweb2" {
  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet3.id
  vpc_security_group_ids = [aws_security_group.sg_others.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "nginxweb2"
  }
}