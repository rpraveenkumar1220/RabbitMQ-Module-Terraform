##creating security group for rabbitmq module
resource "aws_security_group" "SG" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = var.sg_subnet_cidr
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.allow_ssh_cidr
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}

##creating EC2 instance as rabbitmq server
resource "aws_instance" "rabbitmq_server" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [ aws_security_group.SG.id ]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "${var.component}-${var.env}"
      }

  root_block_device {
    encrypted  = true
    kms_key_id = var.kms_key_arn
  }

  user_data = templatefile("${path.module}/userdata.sh", {
    env       = var.env
    component = var.component
  })


}

#### Creating DNS records
resource "aws_route53_record" "dns" {
  zone_id = "Z0860624TQ63X2IAQS8P"
  name    = "${var.component}-${var.env}"
  type    = "A"
  ttl     = 30
  records = [aws_instance.rabbitmq_server.private_ip]
}
