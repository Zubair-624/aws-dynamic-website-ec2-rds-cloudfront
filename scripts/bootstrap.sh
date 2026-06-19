#!/usr/bin/env bash

#---------------Stop the script immediately when an error occurs---------------
set -euo pipefail

#---------------Section 1: Config/Configuration---------------
AWS_PROFILE="zubair-devops"
AWS_REGION="us-east-1"

BUCKET_NAME="zubair-tf-state-project001"
DYNAMODB_TABLE="terraform-state-lock-project001"

#---------------Section 2: S3 Bucket---------------

#-----General Configuration Box-----
# Box Fields: AWS Region, Bucket type, Bucket namespace, Bucket name
# General configuration = create-bucket
echo "==> [S3] Creating bucket: ${BUCKET_NAME}"
aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"


#-----Block Public Access settings for this bucket Box-----
# Block all public access (checkmark by default)
# Block Public Access settings for this bucket = put-public-access-block
echo "==> [S3] Blocking all public access"
aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
    --profile "${AWS_PROFILE}"

#-----Bucket Versioning-----
# Bucket Versioning by default select -> Disable, but we need to this -> enable
# Bucket Versioning = put-bucket-versioning
echo "==> [S3] Enabling Versioning"
aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled \
    --profile "${AWS_PROFILE}"

#-----Default encryption Box-----
# Server-side encryption with Amazon S3 managed keys (SSE-S3) by default -> selected
# Default encryption = put-bucket-encryption
echo "==> Enabling default encryption (SSE-S3)"
aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration '{
    "Rules": [{
    "ApplyServerSideEncryptionByDefault": {
    "SSEAlgorithm": "AES256"
    }
    }]
    }' \
    --profile "${AWS_PROFILE}"


#---------------Section 3: DynamoDB Table---------------

#-----Table details Box-----
# Box Fileds = Table name, Partion key, Sort key - optional
# Partion key = AttributeName = LockID, AttributeType = S(String)
# Default table settings -> under -> "capacity mode(setting) - on demand(value)" = --billing-mode PAY_PAR_REQUEST
echo "==>Creating Table: ${DYNAMODB_TABLE}"
aws dynamodb create-table \
    --table-name "${DYNAMODB_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"

# This command has no equivalent button in the AWS Console.
# In the console, I would just watch the table's status
# change from "Creating" to "Active" with my own eyes.
# Wait for DynamoDB to confirm the table is ready before continuing.
# Stop waiting after 60 seconds to avoid the script getting stuck forever.
echo "==> [DynamoDB] Waiting for table to become Active"
timeout 60 aws dynamodb wait table-exists \
    --table-name "${DYNAMODB_TABLE}" \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"


#---------------Section 4: Confirmation Output---------------
echo ""
echo "Bootstrap complete."
echo ""
echo "   S3 bucket: ${BUCKET_NAME}"
echo "   DynamoDB table: ${DYNAMODB_TABLE}"
echo "   Region: ${AWS_REGION}"
echo ""
echo "   Paste this into terraform/backend.tf:"
echo "   ----------------------------------------"
echo "   terraform {"
echo "     backend \"s3\" {"
echo "       bucket         = \"${BUCKET_NAME}\""
echo "       key            = \"terraform.tfstate\""
echo "       region         = \"${AWS_REGION}\""
echo "       dynamodb_table = \"${DYNAMODB_TABLE}\""
echo "       encrypt        = true"
echo "     }"
echo "   }"
echo "   ----------------------------------------"    
