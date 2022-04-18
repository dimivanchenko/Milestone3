include "root" {
  path = find_in_parent_folders()
}

terraform {
    source = "../..//modules/geoapp"
}
#terraform {
#  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git//."
#}
