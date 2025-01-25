resource "aws_s3_bucket" "my-unique-bucket-08012025-2128" {
  bucket = "my-unique-bucket-08012025-2128"

  tags = {
    Name = "Team Bucket"
  }
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  depends_on = [
    aws_s3_bucket_public_access_block.my_bucket,
  ]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my-unique-bucket-08012025-2128.arn}/public/*"
      }
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "my_bucket" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "team_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my_bucket,
    aws_s3_bucket_public_access_block.my_bucket,
  ]

  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  acl    = "private"
}

resource "aws_s3_object" "public_folder" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  key    = "public/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "hello_world_file" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  key    = "public/hello_world.txt"
  content = "Hello World"
  content_type = "text/plain"
  depends_on = [
    aws_s3_object.public_folder,
  ]
}

resource "aws_s3_object" "hello_world_toto_file" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  key    = "toto/hello_world.txt"
  content = "Hello World"
  content_type = "text/plain"
  depends_on = [
    aws_s3_object.toto_folder,
  ]
}

resource "aws_s3_object" "team_folder" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  key    = "team/"
  acl    = "private"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "toto_folder" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  key    = "toto/"
  acl    = "private"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "tata_folder" {
  bucket = aws_s3_bucket.my-unique-bucket-08012025-2128.id
  key    = "tata/"
  acl    = "private"
  content_type = "application/x-directory"
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.my-unique-bucket-08012025-2128.id
}
