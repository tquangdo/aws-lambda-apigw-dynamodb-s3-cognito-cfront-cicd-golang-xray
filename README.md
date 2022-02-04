# aws-lambda-apigw-dynamodb-s3-cognito-cfront-cicd-golang 🐳

![Stars](https://img.shields.io/github/stars/tquangdo/aws-lambda-apigw-dynamodb-s3-cognito-cfront-cicd-golang?color=f05340)
![Issues](https://img.shields.io/github/issues/tquangdo/aws-lambda-apigw-dynamodb-s3-cognito-cfront-cicd-golang?color=f05340)
![Forks](https://img.shields.io/github/forks/tquangdo/aws-lambda-apigw-dynamodb-s3-cognito-cfront-cicd-golang?color=f05340)
[![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/tquangdo/aws-lambda-apigw-dynamodb-s3-cognito-cfront-cicd-golang/issues/new)

![overview](screenshots/overview.png)

## reference
[viblo](https://viblo.asia/p/serverless-series-golang-bai-1-serverless-va-aws-lambda-gAm5y71XZdb)

## before run terraform
> !! ⚠️⚠️WARNING⚠️⚠️ !!
1. replace `us-west-2` to `us-east-1`
2. replace `<AWS_ACCID>`
3. replace bucketname in `terraform-start/policies/lambda_policy.json`

## bai 4
![bai4](screenshots/bai4.png)
### up src code to lambda
- create `hello-lambda/main.go`
- `hello-lambda$ go mod init list && go get` -> will create `go.mod` & `go.sum`
- create `hello-lambda/build.sh`
- `chmod +x build.sh`
- `hello-lambda$ ./build.sh` -> will create `hello-lambda/list.zip`
### terraform
- edit bucket name in `lambda_policy.json`
```json
"Resource": "arn:aws:s3:::dtq-bucket-golang-up/*"
```
- move `hello-lambda/list.zip` -> `terraform-start/source/list.zip`
- `terraform-start$ terraform init && terraform apply -auto-approve` -> will create AWS lambda & role
```shell
aws lambda invoke --function-name DTQLambdaGoLang response.json
->
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```
- `terraform destroy -auto-approve` -> need `terraform-start/source/list.zip` must exist!
> !! ⚠️⚠️WARNING⚠️⚠️ !!
- `hello-lambda/main.go` & `hello-lambda/build.sh` need as same as repo src code
- src code in `## reference` is different!!! Ex: `hello-lambda/build.sh`
```shell
go build -o main main.go # different with `GOOS=linux go build -o main main.go`
```

## bai 5
![bai5](screenshots/bai5.png)
### user pool
- name=`DTQCognitoUsrPoolGoLang`
### terraform
- will output like code in `bai-5/terraform-start/main.tf`
```yml
output "base_url" {
  value = {
    api = aws_api_gateway_deployment.deployment.invoke_url
    web = aws_s3_bucket.dtq-bucket-golang-spa.website_endpoint
  }
}
```
---
```shell
Outputs:
base_url = {
  "api" = "https://1fvtjd5r25.execute-api.us-east-1.amazonaws.com/staging"
  "web" = "dtq-bucket-golang-spa.s3-website-us-east-1.amazonaws.com"
}
```
### apigw secure
- authorizer name=`DTQAPIGWAuthorizerGoLang`
### login
- edit `user pool > Client ID` in `bai-5/code/login/main.go`
```shell
sh build.sh
aws lambda update-function-code --function-name login --zip-file fileb://login.zip
curl -sX POST -d '{"username":"<GMAIL>", "password": "87654321@bB"}' https://41z6leidch.execute-api.us-east-1.amazonaws.com/staging/login # api gw URL will change after rerun terraform!!!
-> output JSON of "AccessToken", "IdToken"...
```

## bai 6
![bai6](screenshots/bai6.png)
### terraform
- will output like code in `bai-6/terraform-start/main.tf`
```shell
Outputs:
base_url = {
  "api" = "https://oe3pxhe9h5.execute-api.us-east-1.amazonaws.com/staging"
  "web" = "dtq-bucket-golang-spa.s3-website-us-east-1.amazonaws.com"
}
```
- access "web" on browser
![web](screenshots/web.png)
### cfront
- create distribution domain name=`https://d2ixlmqfgvzqk3.cloudfront.net`
- access domain name on browser -> will see
- access `https://d2ixlmqfgvzqk3.cloudfront.net/login` & refresh -> will see ERR `AccessDenied`
### lambda@edge
![l_edge](screenshots/l_edge.webp)
- create function name=`DTQLambdaEdgeGoLang`

## bai 7
![bai7](screenshots/bai7.png)
### production
- before access `https://mvbqvkm3e4.execute-api.us-east-1.amazonaws.com/production/books` need run this (unless will have ERR)
```shell
aws lambda add-permission --function-name arn:aws:lambda:us-east-1:<AWS_ACCID>:function:books_list:production --source-arn "arn:aws:execute-api:us-east-1:<AWS_ACCID>:mvbqvkm3e4/*/GET/books"  --principal apigateway.amazonaws.com --statement-id 4d89f8ab-35b4-49a6-aced-f2e318e8e10f --action lambda:InvokeFunction
->
{
    "Statement": "{\"Sid\":\"4d89f8ab-35b4-49a6-aced-f2e318e8e10f\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"apigateway.amazonaws.com\"},\"Action\":\"lambda:InvokeFunction\",\"Resource\":\"arn:aws:lambda:us-east-1:<AWS_ACCID>:function:books_list:production\",\"Condition\":{\"ArnLike\":{\"AWS:SourceArn\":\"arn:aws:execute-api:us-east-1:<AWS_ACCID>:mvbqvkm3e4/*/GET/books\"}}}"
}
```

## bai 8
### terraform
- after finish, we can get full of AWS resoures: S3 + CFront, lmabda, api gw
- access S3's URL is `access denied` due to block policy
- access CFront's URL is OK!
> !! ⚠️⚠️WARNING⚠️⚠️ !!
- can NOT test login, change PW... because src code just only have `bai-8/terraform-start/source/list.zip`, NOT have others like `login.zip` (bai-6)

### DevToolConnection
- create connection name=`DTQDevToolConnection`
![devconnect](screenshots/devconnect.png)

### 8-1/ CI/CD for Lambda
![bai8_1](screenshots/bai8_1.png)
#### A) pipeline (staging)
- create name=`DTQPipelineGoLangStg`
- repo: https://github.com/tquangdo/codepipeline-list-function (branch:`staging`)
![pipeline](screenshots/pipeline.png)
#### codebuild
- create name=`DTQCodeBuildGoLangStg`
#### CICD finish
- access `https://k9kzwa1osa.execute-api.us-east-1.amazonaws.com/staging/books` will show result without `total`
- add `total` src code in `https://github.com/tquangdo/codepipeline-list-function/blob/staging/main.go` -> CICD will auto run
- access `https://k9kzwa1osa.execute-api.us-east-1.amazonaws.com/staging/books` again will show result with `total`
```json
{
    rows: [
        {
            id: "1",
            name: "Go in Action",
            author: "Erik St. Martin Foreword"
        }
    ],
    total: 1
}
```
#### B) pipeline (production)
- create name=`DTQPipelineGoLangProd`
- repo: https://github.com/tquangdo/codepipeline-list-function (branch:`main`)
![pipelineprod](screenshots/pipelineprod.png)
#### codebuild
- create name=`DTQCodeBuildGoLangProd`
- input Buildspec name=`deployspec.yaml` (`staging` is blank due to default `buildspec.yaml`)
#### run
> !! ⚠️⚠️WARNING⚠️⚠️ !!
- phải làm theo flow là merge từ staging lên nhánh main, nếu mình thay đổi thẳng từ main branch thì nó sẽ không nhận
- access `https://k9kzwa1osa.execute-api.us-east-1.amazonaws.com/production/books` will show result without `total`

### 8-2/ CI/CD for SPA
![bai8_2](screenshots/bai8_2.png)
#### pipeline
- create name=`DTQPipelineGoLangSPA`
- repo: https://github.com/tquangdo/serverless-series-spa
> need change `REACT_APP_API_URL` in `.env-cmdrc`
#### codebuild
- create name=`DTQCodeBuildPGoLangSPA`
- `add Environment variables`
- step Deploy stage: select `S3 > dtq-bucket-golang-spa`
#### run
- have 1 ERR CORS, although enable CORS in API GW
- => need edit src code in `list.zip`, ex: https://github.com/hoalongnatsu/serverless-series/blob/main/bai-4/code-finish/list/main.go
```go
Headers: map[string]string{
			"Content-Type":                "application/json",
			"Access-Control-Allow-Origin": "*",
		},
```
![err](screenshots/err.png)

### 8-3/ terraform for CI/CD
- create `bai-8/terraform-start/cicd.tf` & `bai-8/terraform-start/variables.tf`
```shell
terraform state list
# NOT `terraform apply -auto-approve -target=aws_codebuild_project.click_fe_build -target=aws_codepipeline.click_fe`
terraform apply -auto-approve
```
- => will auto create:
1. codebuild: `click-fe-build-dtq`
2. codepipeline: `click-fe-dtq`
