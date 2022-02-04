provider "aws" {
  region = "us-east-1"
}

locals {
  s3_origin_id = "access-identity-dtq-bucket-golang-spa"
}

output "base_url" {
  value = {
    api = aws_api_gateway_deployment.deployment.invoke_url
    web = aws_s3_bucket.serverless_series_spa.website_endpoint
  }
}
