#!/bin/bash
ENV=${1:-dev}
function prop {
    grep "${1}" env/${ENV}.properties|cut -d'=' -f2
}

function aws_redirect() {
    local json_file=`mktemp`
    printf '{"RedirectAllRequestsTo":{"HostName": "%s", "Protocol": "%s"}}\n' $2 $3 > $json_file
    aws s3api put-bucket-website --bucket $1 \
            --website-configuration file://$json_file
    rm $json_file
}

function put_bucket_policy() {
    local json_file=`mktemp`
    sed "s/$1/$2/g" $3 > $json_file
    aws s3api put-bucket-policy --bucket $2 \
            --policy file://$json_file
    rm $json_file
}

function block_public_access() {
    aws s3api put-public-access-block \
    --bucket $1 \
    --public-access-block-configuration "BlockPublicAcls=$2,IgnorePublicAcls=$2,BlockPublicPolicy=$2,RestrictPublicBuckets=$2"
}

# GLOBAL SPEC
B_NAME=encrypto_s3
ACCOUNT_ID=$(prop 'account.id')
DEPLOY_REGION=$(prop 'account.region')

# BUILD SPEC
DOMAIN=$(prop ''$B_NAME'.domain')
B_FOLDER=$(prop ''$B_NAME'.static_folder')
S_ENTRY=$(prop ''$B_NAME'.static_entry')
S_ERROR=$(prop ''$B_NAME'.error_page')
GET_POLICY=$(prop ''$B_NAME'.get_policy')

npm run build

aws s3api create-bucket --bucket $DOMAIN --region $DEPLOY_REGION
aws s3api create-bucket --bucket www.$DOMAIN --region ${DEPLOY_REGION}

aws s3 sync $B_FOLDER s3://$DOMAIN

block_public_access $DOMAIN false
block_public_access www.$DOMAIN true

put_bucket_policy BUCKET_NAME $DOMAIN $GET_POLICY

aws s3 website s3://$DOMAIN --region $DEPLOY_REGION \
                             --index-document $S_ENTRY \
                             --error-document $S_ERROR

aws_redirect www.$DOMAIN $DOMAIN http