output "ecr_repository" {
  description = "Repository URL"
  value       = join("", aws_ecr_repository.this.*.repository_url)
}

output "ecs_cluster_name" {
  description = ""
  value       = element(concat(aws_ecs_cluster.this.*.name, data.aws_ecs_cluster.this.*.cluster_name, [""]), 0)
}

output "ecs_service_name" {
  description = ""
  value       = element(concat(aws_ecs_service.ecs_service.*.name, aws_ecs_service.ecs_service_with_lb.*.name, [""]), 0)
}

output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group."
  value       = aws_lb_target_group.this.*.arn
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = aws_lb_target_group.this.*.arn_suffix
}

output "target_group_name" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = aws_lb_target_group.this.*.name
}

output "lb_arn" {
  description = "The ARN of the load balancer we created."
  value       = concat(aws_lb.this.*.arn, [""])[0]
}

output "lb_id" {
  description = "The ID of the load balancer we created."
  value       = concat(aws_lb.this.*.id, [""])[0]
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group"
  value       = join("", aws_cloudwatch_log_group.this.*.name)
}
