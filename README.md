# startupco-iam-security
StartupCo Fitness Tracking 

This repository documents both the **AWS Console implementation** and the **Terraform recreation**

# StartupCo IAM Security Architecture

## Project Overview

StartupCo is a fast-growing technology startup that recently launched a fitness-tracking application in AWS.

During the initial product launch, the company prioritized speed and used a shared AWS root account for its 10 employees. Although this allowed the team to deploy resources quickly, it introduced significant security risks.

The purpose of this project was to redesign StartupCo's AWS Identity and Access Management (IAM) environment using **least privilege, role-based access control (RBAC), MFA, secure credential practices, and Infrastructure as Code (IaC).**

The solution was first implemented through the **AWS Management Console** and then recreated and managed using **Terraform**.

---

## The Problem

StartupCo's original AWS environment had several security weaknesses:

* All 10 employees shared the AWS root account.
* Root credentials were shared through team chat.
* Multi-factor authentication (MFA) was not enabled.
* There was no strong account password policy.
* Employees did not have individual IAM identities.
* Permissions were not separated by job responsibility.
* Developers, Operations, Finance, and Data Analysts effectively had the same level of access.
* Development and production resources lacked appropriate identity-based access boundaries.

This created risks involving:

* Unauthorized access
* Credential compromise
* Excessive privileges
* Lack of accountability
* Weak auditability
* Accidental resource modification or deletion
* Increased impact if credentials were compromised

---

# Security Objectives

The redesigned environment focuses on several core security principles:

### Least Privilege

Users should receive only the permissions necessary to perform their job responsibilities.

### Role-Based Access Control

Permissions are assigned through IAM groups based on business function rather than assigning permissions individually to every user.

### Individual Accountability

Each employee receives an individual IAM identity instead of sharing credentials.

### Multi-Factor Authentication

MFA adds an additional authentication factor to reduce the risk associated with compromised passwords.

### Root Account Protection

The AWS root account is reserved for account-level activities that specifically require root privileges and is not used for normal administrative operations.

### Infrastructure as Code

Terraform provides a repeatable and version-controlled method for managing the IAM architecture.

---

# Architecture

The StartupCo environment contains AWS resources supporting the fitness-tracking application.

The architecture includes:

* Amazon EC2 for application workloads
* Amazon S3 for application assets and analytics data
* Amazon RDS for application/user data
* Amazon CloudWatch for monitoring and logging
* AWS Systems Manager for operational management
* AWS IAM for authentication and authorization

The IAM architecture separates access according to four business functions:

```text
                         AWS ACCOUNT
                              |
                        Protected Root
                       Account + MFA
                              |
                    +---------+---------+
                    |                   |
                 AWS IAM          AWS Resources
                    |
       +------------+------------+-------------+
       |            |            |             |
 Developers     Operations     Finance      Analysts
 4 Users         2 Users        1 User       3 Users
       |            |            |             |
       v            v            v             v
 EC2 Management   EC2          Cost          S3 Read
 Dev S3 Access    RDS          Explorer      Analytics
 CloudWatch       CloudWatch   Budgets       RDS Metadata
 Logs             Systems      Resource
                  Manager      Read-Only
```

---

# IAM Group Structure

Four IAM groups were created.

| IAM Group            | Users | Primary Responsibility    |
| -------------------- | ----: | ------------------------- |
| StartupCo-Developers |     4 | Application development   |
| StartupCo-Operations |     2 | Infrastructure operations |
| StartupCo-Finance    |     1 | Cloud cost management     |
| StartupCo-Analysts   |     3 | Data analysis             |

---

# IAM Users

The following IAM users were created:

### Developers

```text
dev-user-01
dev-user-02
dev-user-03
dev-user-04
```

### Operations

```text
ops-user-01
ops-user-02
```

### Finance

```text
finance-user-01
```

### Data Analysts

```text
analyst-user-01
analyst-user-02
analyst-user-03
```

Each user is assigned to the appropriate IAM group rather than receiving permissions directly.

---

# Permission Architecture

## Developers

Developers require enough access to manage application workloads without receiving unrestricted administrative access.

Permissions include:

* Describe EC2 resources
* Start EC2 instances
* Stop EC2 instances
* Reboot EC2 instances
* View CloudWatch Logs
* Access development application files in S3
* Upload application objects
* Delete application objects

Development S3 access is restricted to:

```text
startupco-dev-app-assets-gp
```

This prevents developers from automatically receiving access to analytics or unrelated S3 data.

---

## Operations

Operations personnel require broader infrastructure-management capabilities.

Permissions include:

* Amazon EC2 management
* Amazon RDS management
* Amazon CloudWatch management
* AWS Systems Manager access

Operations does **not** automatically receive unrestricted AWS AdministratorAccess.

This limits unnecessary access to IAM, billing, and account-level security configuration.

---

## Finance

Finance requires visibility into AWS spending without requiring infrastructure administration privileges.

Permissions include:

* AWS Cost Explorer
* AWS Budgets
* Read-only AWS resource visibility

This allows Finance to monitor and manage cloud spending without granting permissions to modify application infrastructure.

---

## Data Analysts

Data Analysts require access to data resources without infrastructure-management privileges.

Permissions include:

* List the analytics S3 bucket
* Read analytics objects
* View RDS resource information

Analytics S3 access is restricted to:

```text
startupco-analytics-data-gp
```

Analysts are not granted permissions such as:

```text
s3:PutObject
s3:DeleteObject
rds:ModifyDBInstance
rds:DeleteDBInstance
```

This supports the principle of least privilege.

---

# S3 Security Design

Two S3 buckets were used to separate application and analytics workloads:

```text
startupco-dev-app-assets-gp
startupco-analytics-data-gp
```

Separating these resources provides stronger access boundaries.

Developers can manage objects associated with application development while Analysts receive read-only access to analytics data.

This reduces unnecessary cross-team access.

---

# Root Account Security

The root account represents the highest privilege level within the AWS account.

The following security improvements were implemented:

* MFA protection
* Elimination of shared root-account usage
* Individual IAM identities
* Root credentials removed from team communication channels
* Root access reserved for tasks requiring root privileges
* Credentials stored securely

The root account should not be used for routine cloud administration.

---

# MFA

MFA was implemented to strengthen authentication.

Instead of relying solely on:

```text
Username + Password
```

authentication can require:

```text
Username
   +
Password
   +
MFA Device
```

This provides an additional layer of protection if a password becomes compromised.

---

# Terraform Implementation

After implementing the security architecture through the AWS Management Console, the environment was recreated and brought under Terraform management.

Terraform allows the IAM configuration to be:

* Version controlled
* Repeatable
* Auditable
* Consistent
* Documented as code

---

# Terraform Project Structure

```text
startupco-iam-security/
|
|-- README.md
|-- .gitignore
|
+-- terraform/
    |
    |-- providers.tf
    |-- variables.tf
    |-- groups.tf
    |-- users.tf
    |-- memberships.tf
    |-- policies.tf
    |-- outputs.tf
    |-- .terraform.lock.hcl
```

### providers.tf

Configures the AWS Terraform provider.

### variables.tf

Defines reusable configuration values such as the AWS region.

### groups.tf

Defines the four IAM groups.

### users.tf

Defines the 10 IAM users.

### memberships.tf

Associates IAM users with their appropriate IAM groups.

### policies.tf

Defines IAM policies and attaches permissions to the appropriate groups.

### outputs.tf

Provides useful information about resources managed by Terraform.

---

# Importing Existing AWS Resources

Because the IAM resources were originally created manually through the AWS Console, Terraform could not simply recreate them.

Doing so could result in errors such as:

```text
EntityAlreadyExists
```

Instead, existing resources were imported into Terraform state.

For example:

```powershell
terraform import aws_iam_group.developers StartupCo-Developers
```

Existing IAM users were also imported into Terraform.

After importing resources, the following command was used:

```powershell
terraform plan
```

A successful import produced:

```text
No changes. Your infrastructure matches the configuration.
```

This demonstrated that the Terraform configuration matched the existing AWS environment.

---

# Terraform Workflow

The following workflow was used throughout the project:

```text
Write Terraform
      |
      v
terraform fmt
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
Review Changes
      |
      v
Import Existing Resources
        OR
terraform apply
```

This approach prevents Terraform from unintentionally duplicating or modifying resources that already exist.

---

# Terraform State Security

Terraform state can contain sensitive infrastructure information.

For that reason, Terraform state files are excluded from this public GitHub repository using `.gitignore`.

Examples include:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
.env
.env.*
*.pem
*.key
```

The Terraform dependency lock file is intentionally retained:

```text
.terraform.lock.hcl
```

This helps maintain consistent Terraform provider versions.

AWS access keys, secret access keys, passwords, MFA information, and other credentials must **never** be committed to the repository.

---

# Security Decisions

Several design decisions were intentionally made during this project.

### Permissions Assigned Through Groups

Permissions are primarily assigned to IAM groups rather than individual users.

This simplifies administration and provides consistent access based on job responsibilities.

### No Shared Root Access

Shared root credentials eliminate individual accountability and create an extremely high-impact credential compromise risk.

Individual IAM identities provide better auditing and access control.

### No AdministratorAccess for Everyone

Employees do not require unrestricted AWS access simply because they work with cloud resources.

Permissions are aligned with job responsibilities.

### Separate S3 Access

Developers and Analysts access different S3 resources.

This reduces unnecessary exposure of data between teams.

### MFA

MFA reduces the likelihood that a stolen password alone can provide access to AWS.

### Infrastructure as Code

Terraform provides a repeatable security configuration that can be reviewed, tested, version controlled, and reproduced.

---

# Challenges Encountered

## Existing AWS Resources

The first challenge occurred because IAM groups and users had already been created through the AWS Console.

Terraform initially attempted to treat these resources as new infrastructure.

### Resolution

Existing resources were imported into Terraform state.

---

## Terraform AWS Region

Terraform initially returned:

```text
Error: invalid AWS Region: Global
```

Although IAM is a global AWS service, the Terraform AWS provider still requires a valid AWS region.

### Resolution

The provider was configured with:

```hcl
provider "aws" {
  region = var.aws_region
}
```

and:

```hcl
default = "us-east-1"
```

---

## Terraform Import Addressing

IAM users were created using Terraform `for_each`.

This required importing resources using their corresponding Terraform resource addresses.

Example:

```text
aws_iam_user.users["dev-user-01"]
```

Correctly addressing each resource allowed Terraform to associate the existing AWS user with the Terraform configuration.

---

## IAM Group Membership Management

The initial implementation used:

```text
aws_iam_group_membership
```

The resource did not support the required import workflow.

### Resolution

The configuration was changed to:

```text
aws_iam_user_group_membership
```

This allowed existing user-to-group relationships to be brought under Terraform management.

---

# Validation

Terraform was used to verify that the Infrastructure as Code configuration matched the AWS environment.

Important commands included:

```powershell
terraform fmt
terraform validate
terraform state list
terraform plan
```

The Terraform state confirmed management of:

* 4 IAM groups
* 10 IAM users
* 10 user-to-group memberships
* IAM policies and policy attachments as they are incorporated into the configuration

---

# Screenshots / Evidence

The final project documentation should include screenshots demonstrating:

1. StartupCo architecture
2. IAM group structure
3. IAM users
4. Users assigned to groups
5. MFA configuration
6. AWS password policy
7. Developer permissions
8. Operations permissions
9. Finance permissions
10. Analyst permissions
11. S3 bucket configuration
12. Successful `terraform validate`
13. Terraform state
14. Successful Terraform imports
15. `terraform plan` results

> **Security Note:** AWS account IDs, ARNs containing account identifiers, credentials, access keys, MFA information, email addresses, and other sensitive information should be reviewed and redacted before screenshots are published publicly.

---

# Security Outcome

The project transformed StartupCo from a shared-root-account model into a structured AWS IAM security architecture.

### Before

```text
10 Employees
     |
     v
Shared Root Credentials
     |
     v
Unrestricted AWS Access
```

### After

```text
10 Individual Users
        |
        v
Role-Based IAM Groups
        |
        v
Least-Privilege Policies
        |
        v
Authorized AWS Resources
```

The redesigned environment improves:

* Authentication
* Authorization
* Accountability
* Auditability
* Credential security
* Separation of duties
* Least-privilege access
* Infrastructure consistency

---

# Key Takeaway

Cloud security is not simply about preventing access.

It is about ensuring that **the right identity has the right level of access to the right resource for the right reason**.

By combining AWS IAM security controls with Terraform, StartupCo moved from an insecure shared-access model toward a more secure, scalable, auditable, and repeatable cloud security architecture.

One thing I intentionally did here: I described the **policy work as still being incorporated**, rather than claiming all 11 planned policy resources are already deployed. Once I finish the policy imports/attachments and get the final clean `terraform plan`, I can update that section with the completed result.


