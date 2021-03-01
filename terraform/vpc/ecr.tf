///*==== The Elastic container registry configuration ======*/
//
//##########################
//# ECR Configuration
//##########################
//resource "aws_ecr_repository" "ecr_private" {
//  name                 = format("ecr_private-%s", var.environment)
//  image_tag_mutability = "MUTABLE"
//
//  image_scanning_configuration {
//    scan_on_push = true
//  }
//
//  tags = merge(
//    {
//      "Name"        = format("ecr_private-%s", var.name),
//      "environment" = var.environment
//    },
//    var.tags,
//  )
//}