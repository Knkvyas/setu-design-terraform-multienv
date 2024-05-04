module "network_module" {
  source = "../../modules/network"

  region               = var.region
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr
  inbound_ports        = var.inbound_ports
  rds_egress_from_port = var.rds_egress_from_port
  rds_egress_to_port   = var.rds_egress_to_port
}

module "rds" {
  source                  = "../../modules/rds"
  env                     = var.env
  availability_zones      = var.availability_zones
  db_identifier           = var.db_identifier
  db_instance_class       = var.db_instance_class
  db_engine               = var.db_engine
  db_engine_version       = var.db_engine_version
  db_storage              = var.db_storage
  db_storage_type         = var.db_storage_type
  db_username             = var.db_username
  backup_retention_period = var.backup_retention_period
  subnet_ids              = module.network_module.db_subnet_ids
  security_group_id       = module.network_module.rds_security_group_id
  depends_on              = [module.network_module]
}

module "access_manager" {
  source                 = "../../modules/access_manager"
  rds_kms_key_id         = module.rds.rds_kms_arn
  rds_secret_manager_arn = module.rds.rds_secret_manager_arn
  depends_on             = [module.rds]
}


module "public_backend_app" {
  source                = "../../modules/public_backend"
  alb_name              = var.alb_name
  frontend_ami_id       = var.public_app_ami
  instance_type         = var.instance_type
  app_iam_profile       = module.access_manager.iam_instance_profile
  security_group_ids    = [module.network_module.public_app_security_group_id]
  alb_sg_id             = [module.network_module.alb_sg_id]
  vpc_id                = module.network_module.vpc_id
  subnet_ids            = module.network_module.app_subnet_ids
  public_subnet_ids     = module.network_module.public_subnet_ids
  alb_listener_port     = var.alb_listener_port
  alb_listener_protocol = var.alb_listener_protocol
  alb_tg_port           = var.alb_tg_port
  alb_tg_protocol       = var.alb_tg_protocol
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  depends_on            = [module.rds, module.access_manager, module.network_module]
}

module "private_backend_app" {
  source                = "../../modules/private_backend"
  nlb_name              = "private-backend-nlb"
  backend_ami_id        = var.private_app_ami
  instance_type         = var.instance_type
  app_iam_profile       = module.access_manager.iam_instance_profile
  security_group_ids    = [module.network_module.private_app_security_group_id]
  vpc_id                = module.network_module.vpc_id
  subnet_ids            = module.network_module.app_subnet_ids
  nlb_listener_port     = var.nlb_listener_port
  nlb_listener_protocol = var.nlb_listener_protocol
  nlb_tg_port           = var.nlb_tg_port
  nlb_tg_protocol       = var.nlb_tg_protocol
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  depends_on            = [module.rds, module.access_manager, module.network_module]
}