# AWS EC2 Security Group Tools

Scripts for extracting existing Security Group assignments on EC2 instances and reattaching them programmatically. All scripts live in `Programmatic-SecurityGroup-EC2-Management/`.

## Prerequisites
- bash, AWS CLI v2 installed and on PATH
- AWS credentials configured (default profile or pass a profile as the second arg)
- Permissions: `ec2:DescribeInstances` and `ec2:ModifyInstanceAttribute`
- Default AWS region in the scripts is `us-east-2`; change it in the scripts if you need another region.

## Extract current Security Groups
Script: `Programmatic-SecurityGroup-EC2-Management/Extract-EC2-SecurityGroups-Mapping.sh`

Input file (`InstanceList`) format (header line is skipped):
```
instance-name
web-01
api-02
```

Command:
```bash
cd Programmatic-SecurityGroup-EC2-Management
chmod +x Extract-EC2-SecurityGroups-Mapping.sh
./Extract-EC2-SecurityGroups-Mapping.sh InstanceList <PROFILE>
```

Output: `SG-details-of-instnaces-from-InstanceList.log` with lines like `instance-name:sg-0123 sg-0456`.

## Attach Security Groups programmatically
Script: `Programmatic-SecurityGroup-EC2-Management/Attach-SecurityGroups-to-EC2-Programmatically.sh`

Input mapping file (`Instance-SG-Mapping`) format (header line is skipped):
```
instance-name:sg-0123 sg-0456
web-01:sg-0123 sg-0789
api-02:sg-0456 sg-0abc
```

Command:
```bash
cd Programmatic-SecurityGroup-EC2-Management
chmod +x Attach-SecurityGroups-to-EC2-Programmatically.sh
./Attach-SecurityGroups-to-EC2-Programmatically.sh Instance-SG-Mapping <PROFILE>
```

Notes:
- `modify-instance-attribute` replaces the entire Security Group set on the instance with the provided list.
- A log file `SG-Attachment-to-Instances-as-par-Instance-SG-Mapping.log` is produced showing the attempted changes.

## LocalStack test setup
Use LocalStack to test the scripts without touching real AWS.

- Requirements: Docker (or `pip install localstack`), AWS CLI v2, and optionally `awslocal` (`pip install awscli-local`).
- Start LocalStack: `docker run --rm -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack`
- Create a test profile: `aws configure --profile localstack` (any keys are accepted).
- Populate sample data (example):  
  `awslocal ec2 run-instances --image-id ami-12345678 --count 1 --instance-type t3.micro --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-01}]'`
- Point the scripts to LocalStack by exporting the endpoint before running them:  
  `export AWS_ENDPOINT_URL=http://localhost:4566`  
  `./Programmatic-SecurityGroup-EC2-Management/Extract-EC2-SecurityGroups-Mapping.sh InstanceList localstack`
- Keep the region consistent (`us-east-1`/`us-east-2`) between your LocalStack resources and the scripts’ `--region` flag.