# Week 6/7 — Deploying Containers, Solving CORS with a Load Balancer and Custom Domain

## Table of Contents:

  - Introduction
  - Health Check 
  - ECS Cluster and ECR Repository
  - Launching Containers on ECS
  - Application Load Balancer
  - Custom Domain Configuration
  - Securing Backend Flask

### Introduction

Week 6/7 objectives revolved around deploying containers on ECS (Elastic Container Service), hosting container images on ECR (Elastic Container Registry), addressing CORS (Cross-Origin Resource Sharing) challenges using a load balancer, and configuring a custom domain. 

### Health Check

health check involves evaluating various aspects of the application to ensure it is functioning properly and meeting the desired requirements.

#### performing health check to test RDS connection:

  - create a test script and make it executable `backend-flask/bin/db/test` as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-fbf3b7a44dbc91b3e8d181ab9bb8a8c92c3e76840879fa7e8e636b917603c521)
  - fix `update-sg-rule` file path in `.gitpod.yml` file as seeen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-370a022e48cb18faf98122794ffc5ce775b2606b09a9d1f80b71333425ec078e)

Run this command manually `export GITPOD_IP=$(curl ifconfig.me)` and `./bin/rds/update-sg-rule` to update security group before running `./bin/db/test` to confirm connection status, you should get the following message as seen in the screenshot below if it is successful.

![](assets/test.png)

#### Health check for the flask app:

  - Modify the `app.py` file with health check endpoint for flask app as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-0014cc1f7ffd53e63ff797f0f2925a994fbd6797480d9ca5bbc5dc65f1b56438)
  - Create a health-check script and make it executable `backend-flask/bin/flask/health-check` as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-01d7ad6d634a3ec30374d54f33e9e024f562ff3eca15fdea99bb1119f41de4be)

Make sure you are in the backend-flask directory then run `./bin/flask/health-check`, you should get the following response as seen below

![]()






