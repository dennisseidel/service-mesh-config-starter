data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}."
  private_zone = false
}
resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "*.d10l.de"
  type    = "A"
  ttl     = "300"
  records = ["${var.ip}"]
}