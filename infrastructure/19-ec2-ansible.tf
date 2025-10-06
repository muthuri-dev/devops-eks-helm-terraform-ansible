resource "aws_instance" "ansible-worker" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3.medium"
  tenancy                     = "default"
  associate_public_ip_address = true 
  subnet_id                   = aws_subnet.production_public_subnet[0].id
  key_name                    = "key"

  tags = {
    Name = "ansible-worker"
  }

  depends_on = [aws_vpc.production_vpc]
}

