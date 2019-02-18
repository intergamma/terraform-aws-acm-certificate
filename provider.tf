provider "aws" {
  alias  = "${var.region}"
  region = "${var.region}"
}
