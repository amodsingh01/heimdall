resource "aws_security_group" "Heimdall-Public-SG" {
  name        = "Heimdall-Public-SG-${random_pet.server.id}-${random_id.server.dec}"
  description = "Allow inbound traffic from anywhere"
  vpc_id      = aws_vpc.Heimdalldata-vpc.id
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = [22, 80, 443, 8080, 8087, 5432, 6379]
    iterator = port
    content {
      description = "Public access ports"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      # ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "Heimdall-Private-SG" {
  name        = "Heimdall-Private-SG-${random_pet.server.id}-${random_id.server.dec}"
  description = "Allow inbound traffic from within Heimdall VPC"
  vpc_id      = aws_vpc.Heimdalldata-vpc.id

  dynamic "ingress" {
    for_each = [0]
    iterator = port
    content {
      #   description = "Public access ports"
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/16"]
      # ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

