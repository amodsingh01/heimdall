resource "aws_eip" "publicip-igw" {
  tags = {
    Name = "Heimdall-igw-${random_pet.server.id}-${random_id.server.dec}"
  }

}