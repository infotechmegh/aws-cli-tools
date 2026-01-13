#!/bin/bash

# LocalStack Test Script for Programmatic Security Group / EC2 Management
# This script sets up LocalStack, creates test data, and runs the existing scripts.

set -e

echo "Starting LocalStack for testing..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start LocalStack
docker run --rm -d --name localstack-test \
    -p 4566:4566 \
    -p 4510-4559:4510-4559 \
    -e SERVICES=ec2 \
    -e DEBUG=1 \
    localstack/localstack:latest

echo "Waiting for LocalStack to start..."
sleep 15

# Set environment variables
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-2
export AWS_ENDPOINT_URL=http://localhost:4566

echo "LocalStack started. Environment configured."

# Create test security groups
echo "Creating test security groups..."
aws ec2 create-security-group --group-name test-sg-1 --description "Test SG 1"
aws ec2 create-security-group --group-name test-sg-2 --description "Test SG 2"

# Get SG IDs
SG1_ID=$(aws ec2 describe-security-groups --group-names test-sg-1 --query 'SecurityGroups[0].GroupId' --output text)
SG2_ID=$(aws ec2 describe-security-groups --group-names test-sg-2 --query 'SecurityGroups[0].GroupId' --output text)

echo "Created SGs: $SG1_ID, $SG2_ID"

# Create test EC2 instances
echo "Creating test EC2 instances..."
INSTANCE1_ID=$(aws ec2 run-instances --image-id ami-12345678 --count 1 --instance-type t3.micro --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-01}]' --query 'Instances[0].InstanceId' --output text)
INSTANCE2_ID=$(aws ec2 run-instances --image-id ami-12345678 --count 1 --instance-type t3.micro --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=api-02}]' --query 'Instances[0].InstanceId' --output text)

echo "Created instances: $INSTANCE1_ID (web-01), $INSTANCE2_ID (api-02)"

# Attach SGs to instances
aws ec2 modify-instance-attribute --instance-id $INSTANCE1_ID --groups $SG1_ID
aws ec2 modify-instance-attribute --instance-id $INSTANCE2_ID --groups $SG2_ID

echo "Attached security groups to instances."

# Create test input files
echo "Creating test input files..."
cat > InstanceList << EOF
instance-name
web-01
api-02
EOF

cat > Instance-SG-Mapping << EOF
instance-name:sg-0123 sg-0456
web-01:$SG1_ID
api-02:$SG2_ID
EOF

echo "Test data created."

# Run the extract script
echo "Running Extract-EC2-SecurityGroups-Mapping.sh..."
chmod +x ../Extract-EC2-SecurityGroups-Mapping.sh
../Extract-EC2-SecurityGroups-Mapping.sh InstanceList

echo "Extract script completed. Check SG-details-of-instnaces-from-InstanceList.log"

# Run the attach script
echo "Running Attach-SecurityGroups-to-EC2-Programmatically.sh..."
chmod +x ../Attach-SecurityGroups-to-EC2-Programmatically.sh
../Attach-SecurityGroups-to-EC2-Programmatically.sh Instance-SG-Mapping

echo "Attach script completed. Check SG-Attachment-to-Instances-as-par-Instance-SG-Mapping.log"

echo "Testing completed. Stopping LocalStack..."
docker stop localstack-test

echo "LocalStack stopped."