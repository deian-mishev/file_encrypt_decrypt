#!/bin/bash
ENV=${1:-dev}
function prop {
    grep "${1}" env/${ENV}.properties|cut -d'=' -f2
}

# GLOBAL SPEC
B_NAME=encrypto_ec2
ACCOUNT_ID=$(prop 'account.id')
DEPLOY_REGION=$(prop 'account.region')

# BUILD SPEC
AMI_OS_TYPE=$(prop ''$B_NAME'.image.ami')
AMI_HARDWARE_TYPE=$(prop ''$B_NAME'.image.type')
EC2_ROLE=$(prop ''$B_NAME'.ec2.role')
EC2_KEY=$(prop ''$B_NAME'.ec2.key_pair')
SECURITY_GROUP=$(prop ''$B_NAME'.vpc.security_group.id')
VPC_SUBNET=$(prop ''$B_NAME'.vpc.subnet.id')
ECR_REPO=$(prop ''$B_NAME'.ecr.repo')

# Authenticate with ecr registry
aws ecr get-login-password --region $DEPLOY_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$DEPLOY_REGION.amazonaws.com

# Build Docker (target instance is x86_64 — force amd64 regardless of build host arch)
docker build --platform linux/amd64 -f Dockerfile -t $B_NAME .

# TAG
docker tag $B_NAME:latest $ACCOUNT_ID.dkr.ecr.$DEPLOY_REGION.amazonaws.com/$ECR_REPO:latest
docker push $ACCOUNT_ID.dkr.ecr.$DEPLOY_REGION.amazonaws.com/$ECR_REPO:latest

cat dockerboot.sh > tempbuild.sh
echo "aws ecr get-login-password --region $DEPLOY_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$DEPLOY_REGION.amazonaws.com" >> tempbuild.sh
echo "docker pull $ACCOUNT_ID.dkr.ecr.$DEPLOY_REGION.amazonaws.com/$ECR_REPO:latest" >> tempbuild.sh
echo "docker run --rm -d -p 80:8080 '$ACCOUNT_ID'.dkr.ecr.'$DEPLOY_REGION'.amazonaws.com/'$ECR_REPO':latest" >> tempbuild.sh

INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_OS_TYPE \
        --count 1 \
        --instance-type $AMI_HARDWARE_TYPE \
        --key-name $EC2_KEY \
        --security-group-ids $SECURITY_GROUP \
        --subnet-id $VPC_SUBNET \
        --iam-instance-profile Name=$EC2_ROLE \
        --output text \
        --user-data file://tempbuild.sh \
        --query "Instances[*].InstanceId")

unlink tempbuild.sh
echo ID: $INSTANCE_ID

# # INSTANCE TEMPLATE IS UPDATED LOGIN OR RUN
# aws ec2 wait instance-running --instance-ids $INSTANCE_ID
# aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
# aws ec2 wait system-status-ok --instance-ids $INSTANCE_ID

# PUBLIC_IP=$(aws ec2 describe-instances \
#     --instance-ids $INSTANCE_ID \
#     --query 'Reservations[*].Instances[*].PublicIpAddress' \
#     --output text)
# ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i env/$EC2_KEY.pem ec2-user@$PUBLIC_IP

# aws ssm send-command \
#     --document-name "AWS-RunShellScript" \
#     --targets "Key=InstanceIds,Values=$INSTANCE_ID" \
#     --output text \
#     --parameters 'commands=[
#         "docker run --rm -d -p 80:8080 '$ACCOUNT_ID'.dkr.ecr.'$DEPLOY_REGION'.amazonaws.com/'$ECR_REPO':latest"
#     ]'
