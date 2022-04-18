locals {
    bucket  = "dim-for-terragrunt-itacad"
    prefix  = "terragrunt/geoapp"
    path    = "/home/diva/.gcp/cred.json"

    project = "geocitizen-345622"
    region  = "europe-west1"
    zone    = "europe-west1-b"

    root_dir = get_parent_terragrunt_dir()
}

 # Generate backend.tf file with remote state configuration
remote_state {
    backend = "gcs"
    generate = {
      path      = "backend.tf"
      if_exists = "overwrite"
    }

    config = {
      credentials = local.path
      bucket  = local.bucket
      prefix  = local.prefix
    }
}

# Generate config.tf file with provider configuration
generate "gcp_conf" {
    path      = "gcp_conf.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF
provider "google" {
    credentials = "/home/diva/.gcp/cred.json"
    project = "${local.project}"
    region = "${local.region}"
    zone = "${local.zone}"
}
EOF
}
