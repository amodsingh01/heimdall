data "aws_route53_zone" "kikrr_cloud-hosted-zone" {
  name = "kikrr.cloud."
}

resource "aws_route53_record" "Heimdall_proxy_manger" {
  zone_id = data.aws_route53_zone.kikrr_cloud-hosted-zone.id
  name    = "heimdall-proxy-manger-${random_pet.server.id}-${random_id.server.dec}.${data.aws_route53_zone.kikrr_cloud-hosted-zone.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Heimdall-proxy-server.public_ip]
}

resource "aws_route53_record" "Heimdall_test_app" {
  zone_id = data.aws_route53_zone.kikrr_cloud-hosted-zone.id
  name    = "heimdall-test-app-${random_pet.server.id}-${random_id.server.dec}.${data.aws_route53_zone.kikrr_cloud-hosted-zone.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Heimdall-test-app.public_ip]
}
resource "aws_route53_record" "Heimdall_guacamole" {
  zone_id = data.aws_route53_zone.kikrr_cloud-hosted-zone.id
  name    = "heimdall-guacamole-${random_pet.server.id}-${random_id.server.dec}.${data.aws_route53_zone.kikrr_cloud-hosted-zone.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Heimdall-Guacamole.public_ip]
}