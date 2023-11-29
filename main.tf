resource "aws_s3_bucket" "wiz" {
  bucket = "my-tf-test-bucket"

  versioning {
    enabled = false
  }
}
