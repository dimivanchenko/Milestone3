variable "ssh_user" {
  description = "user"
  default  = "dim.ivanchenko"
}

data "google_storage_bucket_object_content" "key_server" {

  bucket = "dim-ivanchenko-itacad"
  name   = "ssh/id_rsa.pub"
}
