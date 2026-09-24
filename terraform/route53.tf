# Retrieve existing public hosted zone
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# DNS records used by ACM to validate domain ownership
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Application DNS record pointing to the ALB
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.app_domain
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}