variable "var_environment" {
	default = "dtq"
}

variable "codebuild_role_arn" {
	default = "arn:aws:iam::<AWS_ACCID>:role/service-role/codebuild-DTQCodeBuildPGoLangSPA-service-role"
}

variable "codepipeline_bucket" {
	default = "dtq-bucket-golang-spa"
}

variable "codepipeline_role_arn" {
	default = "arn:aws:iam::<AWS_ACCID>:role/service-role/AWSCodePipelineServiceRole-us-east-1-DTQPipelineGoLangSPA"
}

variable "codestar_connection" {
	default = "arn:aws:codestar-connections:us-east-1:<AWS_ACCID>:connection/2f45b0d7-576a-4934-b21b-a942fe620473"
}