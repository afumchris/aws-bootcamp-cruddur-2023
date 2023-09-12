# Week 10 — CloudFormation Part 1

## Table of Contents


- [Introduction](#introduction)
- [Setup](#setup)
- [Networking Stack](#networking-stack)
- Cluster Stack
- Database Stack
- Service Backend-Flask Stack
- DynamoDB Stack
- CI/CD Nested Stack
- Frontend Stack

### Introduction

This week, We will explore CloudFormation, AWS's infrastructure-as-code service and how CloudFormation can simplify infrastructure management.

### Setup

Install `cfn-lint` and `cfn-guard`:

Edit the `.gitpod.yml` file as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/b8dbbf1703d1703a970bf5d907a0ea0160f4f3e7#diff-370a022e48cb18faf98122794ffc5ce775b2606b09a9d1f80b71333425ec078e) to install `cfn-lint` and `cfn-guard`, as part of our setup process. These tools will help us ensure the quality and security of our AWS CloudFormation templates. `cfn-lint` is used for template linting and checking for AWS best practices, while `cfn-guard` is a policy-as-code framework to enforce additional security and compliance rules.

Create an S3 Bucket:

Create an Amazon S3 bucket `cfn-artifacts-adikaifeanyi` to store your CloudFormation templates using the AWS console and set the bucket name as an env var using the command below.

```sh
export CFN_BUCKET="`cfn-artifacts-adikaifeanyi`"
gp env CFN_BUCKET="`cfn-artifacts-adikaifeanyi`"
```

### Networking Stack






