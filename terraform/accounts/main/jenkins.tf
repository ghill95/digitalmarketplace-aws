resource "aws_key_pair" "jenkins" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.jenkins_public_key}" # injected by Makefile-common
}

module "jenkins_elb_log_bucket" {
  source = "../../modules/jenkins/log_bucket"
  name   = "jenkins-ci.marketplace.team-logs-bucket"
}

module "jenkins" {
  source                        = "../../modules/jenkins/jenkins"
  name                          = "jenkins"
  dev_user_ips                  = "${var.dev_user_ips}"
  jenkins_public_key_name       = "${aws_key_pair.jenkins.key_name}"
  jenkins_instance_profile      = "${aws_iam_instance_profile.jenkins.name}"
  jenkins_wildcard_elb_cert_arn = "${aws_acm_certificate.jenkins_wildcard_elb_certificate.arn}"
  ami_id                        = "ami-2a7d75c0"
  instance_type                 = "t2.large"
  dns_zone_id                   = "${aws_route53_zone.marketplace_team.zone_id}"
  dns_name                      = "ci.marketplace.team"
  log_bucket_name               = "${module.jenkins_elb_log_bucket.bucket_id}"
}

module "jenkins_snapshots" {
  source = "../../modules/jenkins/snapshots"
}