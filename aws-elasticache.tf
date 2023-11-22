resource "aws_elasticache_parameter_group" "Heimdall-PG" {
  name   = "Heimdall-PG-${random_pet.server.id}${random_id.server.id}"
  family = "redis7"

  parameter {
    name  = "notify-keyspace-events"
    value = "AE"
  }
}

resource "aws_elasticache_subnet_group" "Heimdall-Subnet-Group" {
  name       = "Heimdall-Subnet-Group${random_pet.server.id}${random_id.server.id}"
  subnet_ids = [aws_subnet.Heimdalldata-public-subnet-1.id,aws_subnet.Heimdalldata-private-subnet-1.id]
}

resource "aws_elasticache_replication_group" "Heimdall-redis-replication-grp" {
  automatic_failover_enabled  = true
  replication_group_id        = "Heimdall-redis-cluster-${random_pet.server.id}${random_id.server.id}"
  description                 = "Heimdall Redis Elasticache"
  node_type                   = "cache.t2.medium"
  num_cache_clusters          = 2
  parameter_group_name        = aws_elasticache_parameter_group.Heimdall-PG.name
  port                        = 6379
  apply_immediately = true
  transit_encryption_enabled = true 
  auth_token = "heimdalldata12345"
  engine = "redis"
  engine_version = "7.1"
  multi_az_enabled = true
  security_group_ids = [ aws_security_group.Heimdall-Private-SG.id ]
  subnet_group_name = aws_elasticache_subnet_group.Heimdall-Subnet-Group.name
}

