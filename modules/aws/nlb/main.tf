resource "aws_lb" "this" {
  name                       = "${local.name_prefix}-nlb"
  internal                   = var.internal
  load_balancer_type         = "network"
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nlb"
    }
  )
}

resource "aws_lb_target_group" "this" {
  name        = "${local.name_prefix}-eks-nlb-tg"
  port        = var.target_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    unhealthy_threshold = 3
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-nlb-tg"
    }
  )
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_attachment" "eks_node_group" {
  for_each = toset(var.eks_node_group_autoscaling_group_names)

  autoscaling_group_name = each.value
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
