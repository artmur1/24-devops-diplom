// Use keys to create bucket

resource "yandex_storage_bucket" "murchin-bucket2" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "murchin-bucket1"
  acl    = "public-read"
  website {
    index_document = "kitten1.jpg"
  }
}
