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

Manually run the command `export GITPOD_IP=$(curl ifconfig.me)` in the top directory, then navigate to the "backend-flask" directory and execute `./bin/rds/update-sg-rule` to update the security group. After that, run `./bin/db/test` to confirm the connection status. If everything is successful, you should see the expected message as shown in the screenshot below.

![](assets/test.png)

#### Health check for the flask app:

  - Modify the `app.py` file with health check endpoint for flask app as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-0014cc1f7ffd53e63ff797f0f2925a994fbd6797480d9ca5bbc5dc65f1b56438)
  - Create a health-check script and make it executable `backend-flask/bin/flask/health-check` as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-01d7ad6d634a3ec30374d54f33e9e024f562ff3eca15fdea99bb1119f41de4be)

Make sure you are in the backend-flask directory then run `./bin/flask/health-check`, you should get the following response as seen below

![]()

### ECS Cluster and ECR Repository

Create an ECS (Elastic Container Service) cluster and an ECR (Elastic Container Registry) repository to store and manage the container images.

Make sure to set your AWS Account ID as env var:

```
export AWS_ACCOUNT_ID=123456789012
gp env AWS_ACCOUNT_ID=123456789012
```

#### Create Cloudwatch Log Group

To create a CloudWatch log group for ECS cluster and configure the log retention policy for a specific number of days, you can use the following command:

```sh
aws logs create-log-group --log-group-name cruddur
aws logs put-retention-policy --log-group-name cruddur --retention-in-days 1
```

#### Create ECS Cluster

create ECS cluster with the following command:

```sh
aws ecs create-cluster \
 --cluster-name cruddur \
 --service-connect-defaults namespace=cruddur
```

#### Create ECR Repositories and Push Images

Create repository for Python base-Image, backend-flask and frontend-react-js.

##### Python Base-Image:

```sh
aws ecr create-repository \
 --repository-name cruddur-python \
 --image-tag-mutability MUTABLE
```

###### Login to ECR

Login to ECR repository we created above for the Python base-image so that we can push images to the repository:

```sh
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
```

###### Set URL

set path for the address that will map to cruddur-python repository

```
export ECR_PYTHON_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cruddur-python"
echo $ECR_PYTHON_URL
```

###### Pull Python Base-Image

```
docker pull python:3.10-slim-buster
```

To see what images are installed run `docker images`.

###### Tag Image
```
docker tag python:3.10-slim-buster $ECR_PYTHON_URL:3.10-slim-buster
```

###### Push Image
```
docker push $ECR_PYTHON_URL:3.10-slim-buster
```

##### Backend-flask:

To utilize the Python image stored in Amazon Elastic Container Registry (ECR), you need to copy the URI of the image into your backend-flask Dockerfile as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-6f2b9638ec8f4b5a82a7ad3dce05eb963109f5a50c83a9aa342ae6dc0e5f374e). By doing this, you can reference and use the specific image stored in ECR during the Docker build process.

###### Create backend-flask Repository
```
aws ecr create-repository \
 --repository-name backend-flask \
 --image-tag-mutability MUTABLE
```

###### Set URL
```
export ECR_BACKEND_FLASK_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/backend-flask"
echo $ECR_BACKEND_FLASK_URL
```

###### Build Image 
```
docker build -t backend-flask .
```

###### Tag Image
```
docker tag backend-flask:latest $ECR_BACKEND_FLASK_URL:latest
```

###### Push Image
```
docker push $ECR_BACKEND_FLASK_URL:latest
```

##### Frontend-react-js:






