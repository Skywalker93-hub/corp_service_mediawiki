// Create VPC
resource "aws_vpc" "my_net" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wikimedia-network"
  }
}

// Create Internet Gateway
resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_net.id

  tags = {
    Name = "gw"
  }
}

// Create Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_net.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }

  tags = {
    Name = "rt"
  }
}
 
// Zona 1a: Subnet-1 (Public A)
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my_net.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_a"
  }
}

// Private Subnet A
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.my_net.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "private_subnet_a"
  }
}

// Elastic IP for NAT A
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-a"
  }
}

resource "aws_eip" "openvpn_static_ip" {
  domain = "vpc"
  tags = {
    Name = "openvpn-eip-a"
  }
}

// NAT Gateway A
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet1.id
  tags = {
    Name = "nat-gw-a"
  }
  depends_on = [aws_internet_gateway.my_gw]
}

// Private Route Table A
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_net.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt-a"
  }
}


// Zona 1b: Public Subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.my_net.id
  cidr_block              = "10.10.5.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_b"
  }
}

// Subnet-2 (Private B)
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.my_net.id
  cidr_block        = "10.10.2.0/28"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "private_subnet_b"
  }
}

// Zona 1c: Public Subnet C
resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.my_net.id
  cidr_block              = "10.10.6.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_c"
  }
}

// Subnet-3  
resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.my_net.id
  cidr_block        = "10.10.3.0/28"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "private_subnet_c"
  }
}



// Public Associations
resource "aws_route_table_association" "subnet1_assoc" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "public_subnet_b_assoc" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "public_subnet_c_assoc" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.rt.id
}

// Private Associations
resource "aws_route_table_association" "private_subnet_a_assoc" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "subnet2_assoc" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "subnet3_assoc" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.private_rt.id
}

// SSH Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "openvpn-deployer-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

