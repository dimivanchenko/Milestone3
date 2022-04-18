locals {

    profile = "default"
    region  = "eu-north-1"

}


# Generate backend.tf file with remote state configuration
#remote_state {
#  backend = "s3"
#  generate = {
#    path      = "backend.tf"
#    if_exists = "overwrite"
#  }
#
#  config = {
#    bucket  = "dim-for-terragrunt-itacad"
#    region  = "eu-north-1"
#    key     = "terraform.tfstate"
#    encrypt = true
#  }
#}

# Generate config.tf file with provider configuration
generate "aws_conf" {
  path      = "aws_conf.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region   = "${local.region}"
  profile  = "${local.profile}"
}
EOF
}
