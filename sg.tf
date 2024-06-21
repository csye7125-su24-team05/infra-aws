resource "aws_security_group_rule" "cluster-sg-rule" {
  provider          = aws.profile
  for_each          = var.sg_rules
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.cluster_vpc_secruity_group.id
}