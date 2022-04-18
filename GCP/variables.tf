variable "ssh_user" {
  description = "user"
  default  = "dim.xxx"
}

data "google_storage_bucket_object_content" "key_server" {

  bucket = "dim-for-terraform-itacad"
  name   = "ssh/id_rsa.pub"
}
