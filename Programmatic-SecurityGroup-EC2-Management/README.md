# Programmatic Security Group / EC2 Management

Two bash helpers to export current Security Group attachments and reapply them programmatically.

## Prerequisites
- bash, AWS CLI v2 on PATH
- AWS credentials configured (default profile or pass a profile as the second arg)
- Permissions: `ec2:DescribeInstances` and `ec2:ModifyInstanceAttribute`
- Default AWS region in the scripts is `us-east-2`; update the `--region` flag in both scripts if needed.

## Extract existing Security Groups
Script: `Extract-EC2-SecurityGroups-Mapping.sh`

Input file (`InstanceList`) format (first line is skipped):
```
instance-name
web-01
api-02
```

Command:
```bash
chmod +x Extract-EC2-SecurityGroups-Mapping.sh
./Extract-EC2-SecurityGroups-Mapping.sh InstanceList <PROFILE>
```

Note: If using environment variables (AWS_ACCESS_KEY_ID, etc.) instead of a profile, the PROFILE argument can be omitted.

Output: `SG-details-of-instnaces-from-InstanceList.log` with lines like `instance-name:sg-0123 sg-0456`.

## Attach Security Groups programmatically
Script: `Attach-SecurityGroups-to-EC2-Programmatically.sh`

Input mapping file (`Instance-SG-Mapping`) format (first line is skipped):
```
instance-name:sg-0123 sg-0456
web-01:sg-0123 sg-0789
api-02:sg-0456 sg-0abc
```

Command:
```bash
chmod +x Attach-SecurityGroups-to-EC2-Programmatically.sh
./Attach-SecurityGroups-to-EC2-Programmatically.sh Instance-SG-Mapping <PROFILE>
```

Note: If using environment variables (AWS_ACCESS_KEY_ID, etc.) instead of a profile, the PROFILE argument can be omitted.

Notes:
- `modify-instance-attribute` replaces the entire set of Security Groups with the list you provide.
- A log file `SG-Attachment-to-Instances-as-par-Instance-SG-Mapping.log` is generated detailing each attempt.

## LocalStack test setup
Run the scripts against LocalStack to avoid touching real AWS.

- Requirements: Docker (or `pip install localstack`), AWS CLI v2, and optionally `awslocal` (`pip install awscli-local`).
- Start LocalStack: `docker run --rm -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack`
- Configure a test profile: `aws configure --profile localstack` (keys can be dummy).
- Create sample EC2 data (example):  
  `awslocal ec2 run-instances --image-id ami-12345678 --count 1 --instance-type t3.micro --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-01}]'`
- Point AWS CLI to LocalStack by exporting the endpoint before running:  
  `export AWS_ENDPOINT_URL=http://localhost:4566`  
  `./Extract-EC2-SecurityGroups-Mapping.sh InstanceList localstack`
- Ensure the region used in your LocalStack resources matches the `--region` in both scripts (currently `us-east-2`).

### Automated Test Script
A test folder with an automated LocalStack test script is available:
- Navigate to the `test/` folder.
- Run `chmod +x test-localstack.sh && ./test-localstack.sh` to automatically set up LocalStack, create test data, and run both scripts.