# AWS CLI Tools

Utilities and scripts to automate common AWS infrastructure tasks. The repo is designed to grow over time with more functionality and room for new ideas.

## Purpose
- Automate day-to-day AWS infra management tasks via CLI-driven scripts.
- Add new use cases as they emerge (networking, compute, IAM, cost controls, etc.).
- Experiment and iterate on ideas safely before applying them to real environments.

## Prerequisites (common)
- bash, AWS CLI v2 on PATH
- AWS credentials configured (profiles supported)
- Appropriate permissions per script (e.g., EC2 describe/modify for SG tools)
- (Optional) LocalStack + `awslocal` for safe local testing before hitting real AWS

## Repo structure
- `Programmatic-SecurityGroup-EC2-Management/`: scripts to export and reattach EC2 Security Groups (see that folder’s README for usage and LocalStack test flow).
- More folders will be added as new automation use cases are built.

## Quick start
- Prereqs: bash, AWS CLI v2, and credentials configured (or LocalStack for local testing).
- Clone and checkout the branch you need, then follow the README inside each folder.
- Prefer running against LocalStack first when experimenting.

## Contributing / ideas
- Open an issue or PR with new automation ideas.
- Keep scripts idempotent and region-aware; prefer parameters or environment variables over hard-coded values.
- Add a short README to any new folder explaining purpose, inputs, outputs, and safety notes.