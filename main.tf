# main.tf

# Create an EC2 Key Pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-ec2-key"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with the path to your public key
}


resource "aws_vpc" "my_app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyAppVPC"
  }
}

resource "aws_subnet" "app_subnet_a" {
  vpc_id            = aws_vpc.my_app_vpc.id
  cidr_block        = var.subnet_a_cidr_block
  availability_zone = var.availability_zone_a

  tags = {
    Name = "AppSubnetA"
  }
}

resource "aws_subnet" "app_subnet_b" {
  vpc_id            = aws_vpc.my_app_vpc.id
  cidr_block        = var.subnet_b_cidr_block
  availability_zone = var.availability_zone_b

  tags = {
    Name = "AppSubnetB"
  }
}

resource "aws_security_group" "app_security_group" {
  vpc_id = aws_vpc.my_app_vpc.id
  name   = "app-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppSecurityGroup"
  }
}

resource "aws_network_interface" "net_interface_a" {
  subnet_id       = aws_subnet.app_subnet_a.id
  security_groups = [aws_security_group.app_security_group.id]

  tags = {
    Name = "NetInterfaceA"
  }
}

resource "aws_network_interface" "net_interface_b" {
  subnet_id       = aws_subnet.app_subnet_b.id
  security_groups = [aws_security_group.app_security_group.id]

  tags = {
    Name = "NetInterfaceB"
  }
}

resource "aws_internet_gateway" "app_internet_gateway" {
  vpc_id = aws_vpc.my_app_vpc.id

  tags = {
    Name = "AppInternetGateway"
  }
}

resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.my_app_vpc.id

  tags = {
    Name = "AppRouteTable"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_internet_gateway.id
}

resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.app_subnet_a.id
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.app_subnet_b.id
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_eip" "elastic_ip_1" {
  domain            = "vpc"
  network_interface = aws_network_interface.net_interface_a.id
}

resource "aws_eip" "elastic_ip_2" {
  domain            = "vpc"
  network_interface = aws_network_interface.net_interface_b.id
}

resource "aws_instance" "web_server_a" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.net_interface_a.id
    device_index         = 0
  }

  tags = {
    Name = "WebServerA"
  }
}

resource "aws_instance" "web_server_b" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.net_interface_b.id
    device_index         = 0
  }

  tags = {
    Name = "WebServerB"
  }
}

resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "app-db-subnet-group"
  subnet_ids = [aws_subnet.app_subnet_a.id, aws_subnet.app_subnet_b.id]

  tags = {
    Name = "AppDBSubnetGroup"
  }
}

resource "aws_db_instance" "app_database" {
  allocated_storage      = 20
  db_name                = "appdatabase"
  identifier             = "appdatabase"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.app_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.app_security_group.id]
  publicly_accessible    = true

  tags = {
    Name = "AppDatabase"
  }
}

output "route_table_id" {
  value = aws_route_table.app_route_table.id
}

output "instance_1_id" {
  value = aws_instance.web_server_a.id
}

output "instance_2_id" {
  value = aws_instance.web_server_b.id
}
