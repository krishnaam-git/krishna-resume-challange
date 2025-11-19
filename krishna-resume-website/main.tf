resource "aws_s3_bucket" "s3_resume_bucket" {
  bucket = "cloud-resume-krishna"

  tags = {
    Name = "cloud_resume_bucket"
  
  }
}

resource "aws_s3_object" "s3_objects" {
  for_each = fileset("${path.module}/site-contents","**")
  bucket = aws_s3_bucket.s3_resume_bucket.id
  key = each.value

  source = "${path.module}/site-contents/${each.value}"
  etag = filemd5("${path.module}/site-contents/${each.value}")
  content_type = lookup (
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      png  = "image/png"
      jpg  = "image/jpeg"
  
    },
    element(split(".", each.value), length(split(".", each.value)) -1),
    "binary/octet-stream"
  )
}

resource "aws_cloudfront_origin_access_control" "cloud_resume_oac" {
  name                              = "cloud-resume-oac"
  description                       = "Access control for CloudFront to read from S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloud_resume_distributor" {
  enabled = true
  default_root_object = "index.html"

  origin {
    domain_name = "cloud-resume-krishna.s3.us-east-2.amazonaws.com"
    origin_id   = "resume-s3-origin"

    s3_origin_config {
      origin_access_identity = ""
    }

  origin_access_control_id = aws_cloudfront_origin_access_control.cloud_resume_oac.id

  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "resume-s3-origin"

    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
  is_ipv6_enabled = true

  tags = {
    Name = "resume-site-cloudfront"
  }

}

resource "aws_s3_bucket_policy" "allow_cloudfront_distribution" {
  bucket = aws_s3_bucket.s3_resume_bucket.id

  policy = jsonencode({
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::cloud-resume-krishna/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "arn:aws:cloudfront::818473401167:distribution/E3EI2ZHDAC3UJS"
                    }
                }
            }
        ]
      })
}


resource "aws_dynamodb_table" "dynamodb-table" {
  name = "cloud-resume-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

}

resource "aws_dynamodb_table_item" "insert_item_dynamodb" {
  table_name = aws_dynamodb_table.dynamodb-table.name
  hash_key   = aws_dynamodb_table.dynamodb-table.hash_key

  item = <<ITEM
{
  "Id": {"S": "0"},
  "views": {"S": "1"}
}
ITEM
}


data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${path.module}/lambda/getViews.py"
  output_path = "${path.module}/lambda/getViews.zip"

}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})

}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_policy" {
  role = aws_iam_role.lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"

}

resource "aws_lambda_function" "lambda" {
  function_name = "get_total_views"
  handler = "getViews.lambda_handler"
  runtime = "python3.8"
  role = aws_iam_role.lambda_iam_role.arn
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"
}