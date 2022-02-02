#!/bin/bash


# ~~~~~~~~~~~ 1) S3 ~~~~~~~~~~~
# dtq-bucket-golang-up
# aws s3 rm s3://dtq-bucket-golang-up/ --recursivezip
# aws s3api delete-bucket --bucket dtq-bucket-golang-up
## IF ERR="can NOT delete due to bucket policy" then must delete manually!!!


# ~~~~~~~~~~~ 2) Lambda ~~~~~~~~~~~
# aws lambda delete-function --function-name DTQLambdaGoLang


# ~~~~~~~~~~~ 3) CWatch ~~~~~~~~~~~
log_group_name=$(aws logs describe-log-groups --log-group-name-prefix /aws/lambda --query 'logGroups[*].logGroupName' --output text) # replace "/aws/lambda" <=> "<LOGGROUP_NAME>"
for item in $log_group_name; do
    aws logs delete-log-group --log-group-name $item
done


# ~~~~~~~~~~~ 14) EC2 ~~~~~~~~~~~
## ~~~~~~~~~~~ list SG!!!
# instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=<EC2_NAMEVALUE>" --query "Reservations[].Instances[].InstanceId" --output text)
# sgs=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].SecurityGroups[].GroupId' --output text)

## ~~~~~~~~~~~ EC2!!!
# aws ec2 terminate-instances --instance-ids $instance_id

## ~~~~~~~~~~~ delete SG!!!
# sleep 45
# echo $sgs
# for item in $sgs; do
#     aws ec2 delete-security-group --group-id $item
# done


# ~~~~~~~~~~~ 4) Role & Policy ~~~~~~~~~~~
## ~~~~~~~~~~~ ROLE!!!
# roles=$(aws iam list-roles --query 'Roles[?contains(RoleName, `DTQ`)].RoleName' --output text) # replace "DTQ" <=> "<ROLE_NAME>"
# for role in $roles; do
#   policies=$(aws iam list-attached-role-policies --role-name=$role --query AttachedPolicies[*][PolicyArn] --output text)
#   for policy_arn in $policies; do
#     aws iam detach-role-policy --policy-arn $policy_arn --role-name $role
#   done
#   aws iam delete-role --role-name $role
# done

## IF ERR="Cannot delete entity, must remove roles from instance profile first"!!!
# aws iam remove-role-from-instance-profile --instance-profile-name $(aws iam list-instance-profiles-for-role --role-name <ROLE_NAME> --query 'InstanceProfiles[*].InstanceProfileName' --output text) --role-name <ROLE_NAME>
## -> run "Role" again!

## ~~~~~~~~~~~ POLICY!!!
policies=$(aws iam list-policies --query 'Policies[?contains(PolicyName, `AWSLambdaBasicExecutionRole-`)].{ARN:Arn}' --output text) # replace "DTQ" <=> "<POLICY_NAME>"
for policy_arn in $policies; do
    aws iam delete-policy --policy-arn $policy_arn
done

## ~~~~~~~~~~~ NOTE!!!
# aws iam list-role-policies --role-name DTQRoleDel2
# ->
# {
#     "PolicyNames": []
# }

# aws iam list-attached-role-policies --role-name DTQRoleDel2
# ->
# {
#     "AttachedPolicies": [
#         {
#             "PolicyName": "DTQPolicyDel2",
#             "PolicyArn": "arn:aws:iam::<ACC_ID>:policy/DTQPolicyDel2"
#         }
#     ]
# }


# ~~~~~~~~~~~ 5) RDS ~~~~~~~~~~~
# aws rds delete-db-instance --db-instance-identifier <INSTANCE_NAME> --skip-final-snapshot


# ~~~~~~~~~~~ 6) Step function ~~~~~~~~~~~
# aws stepfunctions delete-state-machine --state-machine-arn $( aws stepfunctions list-state-machines --query 'stateMachines[?name == `<MACHINE_NAME>`]'.stateMachineArn --output text )


# ~~~~~~~~~~~ 7) Cloudformation ~~~~~~~~~~~
# aws cloudformation delete-stack --stack-name <STACK_NAME>


# ~~~~~~~~~~~ 8) Elastic Beanstalk ~~~~~~~~~~~
# aws elasticbeanstalk delete-application --application-name <APP_NAME> --terminate-env-by-force


# ~~~~~~~~~~~ 9) Route53 ~~~~~~~~~~~
## NOTE: first, need delete manually all records except SOA & NS!!!
# aws route53 delete-hosted-zone --id  $(aws route53 list-hosted-zones-by-name --dns-name <DOMAIN_NAME> --query 'HostedZones[*].Id' --output text)


# ~~~~~~~~~~~ 10) ACM ~~~~~~~~~~~
# aws acm delete-certificate --certificate-arn $(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='<DOMAIN_NAME>'].CertificateArn" --output text)


# ~~~~~~~~~~~ 11) SNS ~~~~~~~~~~~
# aws sns delete-topic --topic-arn $(aws sns list-topics --query "Topics[?contains(TopicArn, '<TOPIC_NAME>')].TopicArn" --output text)


# ~~~~~~~~~~~ 12) Container ~~~~~~~~~~~
## ~~~~~~~~~~~ service!!!
# aws ecs delete-service --service <SERVICE_NAME> --force --cluster <CLUSTER_NAME>

## ~~~~~~~~~~~ cluster!!!
# aws ecs delete-cluster --cluster <CLUSTER_NAME>

## ~~~~~~~~~~~ task definition!!!
# aws ecs deregister-task-definition --task-definition <TASKDEF_NAME>:<REVISION_NO>

## ~~~~~~~~~~~ ECR!!!
# aws ecr delete-repository --force --repository-name <REPO_NAME>


# ~~~~~~~~~~~ 13) CICD ~~~~~~~~~~~
## ~~~~~~~~~~~ pipeline!!!
# aws codepipeline delete-pipeline --name <PIPELINE_NAME> 

## ~~~~~~~~~~~ deploy!!!
# aws deploy delete-application --application-name <DEPLOYAPP_NAME> 

## ~~~~~~~~~~~ build!!!
# aws codebuild delete-project --name <PROJ_NAME> 

## ~~~~~~~~~~~ commit!!!
# aws codecommit delete-repository --repository-name <REPO_NAME> 


# ~~~~~~~~~~~ 15) api gateway ~~~~~~~~~~~
# aws apigateway delete-rest-api --rest-api-id $(aws apigateway get-rest-apis --query "items[?contains(name, 'DTQ')].id" --output text)


# ~~~~~~~~~~~ 16) secret manager ~~~~~~~~~~~
# aws secretsmanager delete-secret --secret-id <SECRET_NAME> --force-delete-without-recovery


# ~~~~~~~~~~~ the others) RDS Proxy, SSM, EFS, AWS batch, SQS, SES, LB ~~~~~~~~~~~