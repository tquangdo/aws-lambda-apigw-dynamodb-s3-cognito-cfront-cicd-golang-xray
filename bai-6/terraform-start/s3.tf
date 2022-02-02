resource "aws_s3_bucket" "dtq-bucket-golang-spa" {
  bucket = "dtq-bucket-golang-spa"
  acl    = "public-read"
  policy = file("policies/s3_spa_policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "dtq-bucket-golang-upload" {
  bucket = "dtq-bucket-golang-upload"
  acl    = "public-read"
  policy = file("policies/s3_upload_policy.json")
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "PUT",
      "POST",
      "DELETE"
    ]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "null_resource" "yarn_install" {
  depends_on = [

  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/front-end && yarn install
    EOT
  }
}

resource "null_resource" "replace" {
  depends_on = [
    null_resource.yarn_install,
    aws_api_gateway_deployment.deployment
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/front-end && sed -i -- "s|staging_api|${aws_api_gateway_deployment.deployment.invoke_url}|g" .env-cmdrc
    EOT
  }
}

resource "null_resource" "yarn_build" {
  depends_on = [
    null_resource.replace
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/front-end && yarn build:staging
    EOT
  }
}

resource "null_resource" "upload" {
  depends_on = [
    null_resource.yarn_build,
    aws_s3_bucket.dtq-bucket-golang-spa
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/front-end && aws s3 cp build s3://dtq-bucket-golang-spa --recursive
    EOT
  }
}
