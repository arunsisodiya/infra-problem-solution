/*==== AWS S3 configuration ======*/

##########################
# S3 Bucket configuration
##########################
resource "aws_s3_bucket" "static_bucket" {
  bucket = var.bucket_name
  acl = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
  }
}

################################
# S3 Bucket policy configuration
################################
resource "aws_s3_bucket_policy" "s3_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = jsonencode({
    "Id": "s3_bucket_policy",
    "Version": "2012-10-17",
    "Statement": [
      {
        Sid: "AllowPublicAccess",
        Action: [
          "s3:GetObject"
        ],
        Effect: "Allow",
        Resource: "arn:aws:s3:::${var.bucket_name}/*",
        Principal: "*"
      }
    ]
  })
}