resource "aws_acm_certificate" "default" {
  provider                  = "aws.eu-west-1"
  domain_name               = "${var.domain_name}"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${var.subject_alternative_names}"]
  tags                      = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "default" {
  name         = "${var.zone_name}"
  private_zone = false
}

resource "aws_acm_certificate_validation" "default" {
  provider        = "aws.eu-west-1"
  certificate_arn = "${aws_acm_certificate.default.arn}"

  validation_record_fqdns = ["${aws_route53_record.default.*.fqdn}"]
}

resource "aws_route53_record" "default" {
  count   = "${length(var.subject_alternative_names) + 1}"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_type")}"
  ttl     = "${var.ttl}"
  records = ["${lookup(aws_acm_certificate.default.domain_validation_options[count.index],"resource_record_value")}"]
  
  allow_overwrite = true
}
