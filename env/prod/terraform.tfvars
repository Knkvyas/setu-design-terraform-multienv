env                   = "prod"
region                = "us-east-1"
public_app_ami        = "ami-07caf09b362be10b8"
alb_name              = "public-backend-alb"
alb_tg_port           = 80
alb_tg_protocol       = "HTTP"
alb_listener_port     = 80
alb_listener_protocol = "HTTP"
private_app_ami       = "ami-07caf09b362be10b8"
nlb_name              = "private-backend-nlb"
nlb_tg_port           = 80
nlb_tg_protocol       = "TCP"
nlb_listener_port     = 80
nlb_listener_protocol = "TCP"
instance_type         = "t2.micro"
min_size              = 0
max_size              = 3
desired_capacity      = 1

db_identifier           = "mysql-database"
db_instance_class       = "db.t3.micro"
db_engine               = "mysql"
db_engine_version       = "8.0"
db_storage              = 20
db_storage_type         = "gp2"
db_username             = "admin"
backup_retention_period = 7

availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_cidr             = "10.0.0.0/16"
inbound_ports        = ["80", "443"]
rds_egress_from_port = 3306
rds_egress_to_port   = 3306