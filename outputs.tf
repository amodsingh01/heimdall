output "Heimdall_UI" {
  value = "https://${aws_route53_record.Heimdall_proxy_manger.name}  username:admin, password:${aws_instance.Heimdall-proxy-server.id}"
}

output "Guacamole_UI" {
  value = "https://${aws_route53_record.Heimdall_guacamole.name}/guacamole   username:password is guacadmin/guacadmin"
}

output "Test_app_UI" {
  value = "https://${aws_route53_record.Heimdall_test_app.name}"
}

output "RDS_Details" {
value = "username: postgres,password:heimdalldata     ,default_db_name: heimdalldata"
  
}

output "Elasticache_Password" {
  value = "Password is : heimdalldata12345"
  
}