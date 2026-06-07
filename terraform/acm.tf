locals {
  cert_domains = [var.domain_name, "www.${var.domain_name}", "api.${var.domain_name}"]
}

resource "aws_acm_certificate" "site" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}", "api.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = toset(local.cert_domains)

  zone_id = var.hosted_zone_id
  name    = one([for dvo in aws_acm_certificate.site.domain_validation_options : dvo.resource_record_name if dvo.domain_name == each.value])
  type    = one([for dvo in aws_acm_certificate.site.domain_validation_options : dvo.resource_record_type if dvo.domain_name == each.value])
  records = [one([for dvo in aws_acm_certificate.site.domain_validation_options : dvo.resource_record_value if dvo.domain_name == each.value])]

  ttl             = 300
  allow_overwrite = true
}
