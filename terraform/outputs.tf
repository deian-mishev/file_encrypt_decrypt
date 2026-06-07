output "site_bucket" {
  description = "Name of the S3 bucket hosting the static frontend"
  value       = aws_s3_bucket.site.id
}

output "site_cloudfront_domain" {
  description = "CloudFront domain serving the apex domain"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "www_cloudfront_domain" {
  description = "CloudFront domain serving the www subdomain"
  value       = aws_cloudfront_distribution.www.domain_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository that stores the encrypto backend image"
  value       = aws_ecr_repository.encrypto.repository_url
}

output "backend_instance_id" {
  description = "ID of the EC2 instance running the encrypto backend (api.encrypto.link)"
  value       = aws_instance.encrypto.id
}

output "backend_public_ip" {
  description = "Public IP address of the encrypto backend instance, also published as api.encrypto.link"
  value       = aws_instance.encrypto.public_ip
}

output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate covering the apex, www and api domains"
  value       = aws_acm_certificate.site.arn
}
