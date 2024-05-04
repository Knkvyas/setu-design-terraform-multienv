output "vpc_id" {
  value = module.network_module.vpc_id
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "alb_dns_name" {
  value = module.public_backend_app.application_load_balancer_dns
}

output "nlb_dns_name" {
  value = module.private_backend_app.nlb_dns_name
}