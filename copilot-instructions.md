## Repository purpose

- This repo contains small, focused scripts and utilities for **automating AWS infrastructure management** using the AWS CLI.
- Existing and future folders are generally **single-use-case oriented** (for example, managing EC2 Security Groups programmatically).
- New ideas and experiments are welcome, but should be kept **safe, testable, and well documented**.

## Project structure (current)

- `README.md`: High-level overview, common prerequisites, and repo purpose.
- `Programmatic-SecurityGroup-EC2-Management/`:  
  - Bash scripts to export Security Groups attached to EC2 instances and reattach them programmatically.  
  - Has its own `README.md` that documents inputs, outputs, and a LocalStack-based test workflow.

## General conventions

- **Language & tooling**
  - Scripts are primarily **bash** and use **AWS CLI v2**.
  - Prefer **parameters or environment variables** over hard-coded values (region, profile, endpoints).
  - Aim for **idempotent** operations where possible.

- **AWS usage**
  - Default to **non-destructive** operations unless clearly documented.
  - For destructive changes (e.g., SG replacement, deletes), always:
    - Log clearly what was changed.
    - Provide a way to dry-run or at least clearly separate “read” from “write” behavior.

- **Testing with LocalStack**
  - Where feasible, add a **LocalStack test flow** so scripts can be exercised without touching real AWS.
  - Prefer using `AWS_ENDPOINT_URL` or explicit `--endpoint-url` flags to point to LocalStack.
  - Document LocalStack setup and example commands in each feature folder’s README.

## Style for new scripts

- Use **clear, descriptive variable names** (`INSTANCE_LIST`, `PROFILE`, `SG_INSTANCE_MAP`, etc.).
- At the top of each script:
  - Brief **comment block** describing purpose, inputs, and expected outputs.
  - Note any **required permissions** (e.g., `ec2:DescribeInstances`, `ec2:ModifyInstanceAttribute`).
- Always write to a **log file** when performing changes, with:
  - Input parameters (instance ID, name, SG list, etc.).
  - The exact AWS CLI commands’ output or a summary.

## Documentation expectations

- Each new folder should have a **README** that includes:
  - Purpose and high-level design.
  - Prerequisites specific to that feature (beyond the repo-level ones).
  - Input file formats (with small examples).
  - Example commands to run the script(s).
  - Any LocalStack or safety notes.

## How Copilot / agents should help

- When adding new functionality:
  - Reuse existing **patterns and naming** where possible.
  - Suggest **LocalStack-backed** test harnesses and example invocations.
  - Ensure new scripts integrate cleanly with the repo’s README and folder-level docs.
- When modifying existing scripts:
  - Preserve current behavior by default; if changes are breaking or risky, annotate them clearly in comments and README.
  - Keep region and profile handling explicit and configurable.

