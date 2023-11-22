resource "aws_db_subnet_group" "Heimdall-rds-subnet-group" {
  name       = "heimdall-rds-subnet-group-${lower("${random_pet.server.id}-${random_id.server.id}")}"
  subnet_ids = [aws_subnet.Heimdalldata-private-subnet-1.id, aws_subnet.Heimdalldata-public-subnet-1.id]

  tags = {
    Name = "heimdall-rds-subnet-group-${random_pet.server.id}-${random_id.server.id}"
  }
}

resource "aws_db_instance" "Heimdall-RDS" {

  identifier             = "heimdall-rds-${lower("${random_pet.server.id}${random_id.server.id}")}"
  multi_az               = true
  username               = "postgres"
  password               = "heimdalldata"
  db_name                = "heimdalldata"
  engine                 = "postgres"
  engine_version         = "15.2"
  instance_class         = "db.t3.micro"
  storage_type           = "gp3"
  allocated_storage      = 20
  backup_retention_period = 7
  vpc_security_group_ids = [aws_security_group.Heimdall-Public-SG.id]
  db_subnet_group_name   = aws_db_subnet_group.Heimdall-rds-subnet-group.name
  parameter_group_name   = "default.postgres15"
  skip_final_snapshot = true
}

resource "aws_db_instance" "Heimdall-RDS-Replica" {

  identifier             = "heimdall-read-replica${lower("${random_pet.server.id}${random_id.server.id}")}"
  replicate_source_db = aws_db_instance.Heimdall-RDS.identifier
  instance_class         = "db.t3.micro"
  vpc_security_group_ids = [aws_security_group.Heimdall-Private-SG.id]
  skip_final_snapshot = true
}