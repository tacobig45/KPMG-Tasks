terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 0.14.0"
}

provider "aws" {
  region = var.region
}

#Creation of VPC Resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CustomVPC"
  }
}

#Creation of Webserver Public Subnet
resource "aws_subnet" "webpub" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Webpub"
  }

}



#Creation of App Server Private Subnet
resource "aws_subnet" "apppvt" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Apppvt"
  }

}



#Creation of DB Server Private Subnet
resource "aws_subnet" "dbpvt" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "dbpvt"
  }

}

#Creation of DB Server Private Subnet2 for Subnet Group
resource "aws_subnet" "dbpvt2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "dbpvt2"
  }

}


#Creating Internet Gateway and attaching it to VPC for Internet Access

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

#Creating Public and Private Route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "PublicRoute"
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = []
  tags = {
    Name = "PrivateRoute"
  }

}

#Associating Public Subnet of webserver
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.webpub.id
  route_table_id = aws_route_table.public.id


}


#Associating Internet gateway to Route Table
#resource "aws_route" "r" {
# route_table_id         = aws_route_table.public.id
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = aws_internet_gateway.igw.id
#}

#Associating DB and App subnets to Private Route tables
resource "aws_route_table_association" "pvta" {
  subnet_id      = aws_subnet.apppvt.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "pvtc" {
  subnet_id      = aws_subnet.dbpvt.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "pvtd" {
  subnet_id      = aws_subnet.dbpvt2.id
  route_table_id = aws_route_table.private.id
}


#Creation of Elastic IP and attaching it to Nat Gateway
resource "aws_eip" "example" {
  vpc = true


}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.webpub.id

  tags = {
    Name = "gw NAT"
  }
}

#Creating Security Group and associating with proper inbound and outbound rules
resource "aws_security_group" "web" {
  name        = "websg"
  description = "Allow ssh into the instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "webserver-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "appserversg"
  description = "Allow jump into the instance through webserver sg"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "appserver-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "dbserversg"
  description = "Allow mysql queries on RDS instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "dbserver-sg"
  }
}

#Creating NACL and associating with Public and Private Subnets
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "PublicNACL"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24" # Allowing Incoming Traffic only from Webserver CIDR ranges
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "PrivateNACL"
  }
}

#Associating public and private subnets with dedicated subnets
resource "aws_network_acl_association" "web" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.webpub.id
}


resource "aws_network_acl_association" "app" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.apppvt.id
}



resource "aws_network_acl_association" "db" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.dbpvt.id
}



resource "aws_security_group_rule" "app" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "webo" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "db" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["10.0.3.0/24"]
  security_group_id = aws_security_group.db.id
}