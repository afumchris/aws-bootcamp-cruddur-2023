# Week 6/7 — Deploying Containers, Solving CORS with a Load Balancer and Custom Domain

## Table of Contents:

  - [Introduction](#introduction)
  - [Health Check](#health-check) 
  - [ECS Cluster and ECR Repository](#ecs-cluster-and-ecr-repository)
  - [Launching Containers on ECS](#launching-containers-on-ecs)
  - [Application Load Balancer](#application-load-balancer)
  - Custom Domain Configuration
  - Securing Backend Flask

### Introduction

Week 6/7 objectives revolved around deploying containers on ECS (Elastic Container Service), hosting container images on ECR (Elastic Container Registry), addressing CORS (Cross-Origin Resource Sharing) challenges using a load balancer, and configuring a custom domain. 

### Health Check

health check involves evaluating various aspects of the application to ensure it is functioning properly and meeting the desired requirements.

#### performing health check to test RDS connection:

  - create a test script and make it executable `backend-flask/bin/db/test` as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-fbf3b7a44dbc91b3e8d181ab9bb8a8c92c3e76840879fa7e8e636b917603c521)
  - fix `update-sg-rule` file path in `.gitpod.yml` file as seeen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-370a022e48cb18faf98122794ffc5ce775b2606b09a9d1f80b71333425ec078e)

Manually run the command `export GITPOD_IP=$(curl ifconfig.me)` in the top directory, then navigate to the `backend-flask` directory and execute `./bin/rds/update-sg-rule` to update the security group. After that, run `./bin/db/test` to confirm the connection status. If everything is successful, you should see the expected message as shown in the screenshot below.

![](assets/test.png)

#### Health check for the flask app:

  - Modify the `app.py` file with health check endpoint for flask app as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-0014cc1f7ffd53e63ff797f0f2925a994fbd6797480d9ca5bbc5dc65f1b56438)
  - Create a health-check script and make it executable `backend-flask/bin/flask/health-check` as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-01d7ad6d634a3ec30374d54f33e9e024f562ff3eca15fdea99bb1119f41de4be)

Make sure you are in the backend-flask directory then run `./bin/flask/health-check`, you should get the following response as seen below

![]()

### ECS Cluster and ECR Repository

Create an ECS (Elastic Container Service) cluster and an ECR (Elastic Container Registry) repository to store and manage the container images.

it is necessary to configure your AWS Account ID and HONEYCOMB API KEY as an environment variable:

```sh
export AWS_ACCOUNT_ID=123456789012
gp env AWS_ACCOUNT_ID=123456789012

export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=$HONEYCOMB_API_KEY"
gp env OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=$HONEYCOMB_API_KEY"
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

##### Python Base-Image

Execute this command to create a cruddur-python repository:

```sh
aws ecr create-repository \
 --repository-name cruddur-python \
 --image-tag-mutability MUTABLE
```

###### Login to ECR

To log in to the ECR repository you created for the Python base image and enable pushing images to the repository, you can execute the following command:

```sh
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
```

###### Set URL

set path for the address that will map to cruddur-python repository with this command:

```sh
export ECR_PYTHON_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cruddur-python"
echo $ECR_PYTHON_URL
```

###### Pull Python Base-Image:

```sh
docker pull python:3.10-slim-buster
```

To see what images are installed run `docker images`.

###### Tag Image:
```sh
docker tag python:3.10-slim-buster $ECR_PYTHON_URL:3.10-slim-buster
```

###### Push Image:
```sh
docker push $ECR_PYTHON_URL:3.10-slim-buster
```

##### Backend-flask

To utilize the Python image stored in Amazon Elastic Container Registry (ECR), you need to copy the URI of the image into your backend-flask Dockerfile as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-6f2b9638ec8f4b5a82a7ad3dce05eb963109f5a50c83a9aa342ae6dc0e5f374e). By doing this, you can reference and use the specific image stored in ECR during the Docker build process.

###### Create backend-flask Repository:
```sh
aws ecr create-repository \
 --repository-name backend-flask \
 --image-tag-mutability MUTABLE
```

###### Set URL:
```sh
export ECR_BACKEND_FLASK_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/backend-flask"
echo $ECR_BACKEND_FLASK_URL
```

###### Build Image:
```sh
docker build -t backend-flask .
```

###### Tag Image:
```sh
docker tag backend-flask:latest $ECR_BACKEND_FLASK_URL:latest
```

###### Push Image:
```sh
docker push $ECR_BACKEND_FLASK_URL:latest
```

##### Frontend-react-js


Go to the AWS Management Console and access AWS ECR (Elastic Container Registry). Navigate to the Repositories section to confirm if the images were created successfully and are visible in the registry.

### Launching Containers on ECS
Deploy the containers onto the ECS cluster, utilizing the container images stored in the ECR repository.

#### Create Task and Execution Roles for Task definition

Prior to creating the task and execution roles for the task definition, set the environment variables in AWS System Manager Parameter Store using the following commands:

```sh
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/AWS_ACCESS_KEY_ID" --value $AWS_ACCESS_KEY_ID
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/AWS_SECRET_ACCESS_KEY" --value $AWS_SECRET_ACCESS_KEY
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/CONNECTION_URL" --value $PROD_CONNECTION_URL
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/ROLLBAR_ACCESS_TOKEN" --value $ROLLBAR_ACCESS_TOKEN
aws ssm put-parameter --type "SecureString" --name "/cruddur/backend-flask/OTEL_EXPORTER_OTLP_HEADERS" --value "x-honeycomb-team=$HONEYCOMB_API_KEY"
```

Navigate to the AWS Management Console and select AWS Systems Manager. From there, access the Parameter Store to ensure that the values were accurately set.

![](assets/parameter-store.png)

Based on the provided commits, create separate files holding the AWS policies for the `CruddurServiceExecutionRole` [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-140ff34ff4760d0e7e2c4fbf70b1c1d07b7ac054bb074512615f53f6f03f3398) and `CruddurServiceExecutionPolicy` [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-d48147539acff3a143fc19696e28187238e9a56bf6788bcd816a34572897a6f6). Then, proceed to establish the ExecutionRole and associate the policies using the provided commands:


```sh
aws iam create-role \
  --role-name CruddurServiceExecutionRole \
  --assume-role-policy-document file://aws/policies/service-assume-role-execution-policy.json

aws iam put-role-policy \
  --policy-name CruddurServiceExecutionPolicy \
  --role-name CruddurServiceExecutionRole \
  --policy-document file://aws/policies/service-execution-policy.json

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess \
  --role-name CruddurServiceExecutionRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy \
  --role-name CruddurServiceExecutionRole
```

Next, create the TaskRole named "CruddurTaskRole" and attach the necessary policies to it:

```sh
aws iam create-role \
    --role-name CruddurTaskRole \
    --assume-role-policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[\"sts:AssumeRole\"],
    \"Effect\":\"Allow\",
    \"Principal\":{
      \"Service\":[\"ecs-tasks.amazonaws.com\"]
    }
  }]
}"

aws iam put-role-policy \
  --policy-name SSMAccessPolicy \
  --role-name CruddurTaskRole \
  --policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[
      \"ssmmessages:CreateControlChannel\",
      \"ssmmessages:CreateDataChannel\",
      \"ssmmessages:OpenControlChannel\",
      \"ssmmessages:OpenDataChannel\"
    ],
    \"Effect\":\"Allow\",
    \"Resource\":\"*\"
  }]
}"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess \
  --role-name CruddurTaskRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess \
  --role-name CruddurTaskRole
```

Go to the AWS Management Console and access the IAM (Identity and Access Management) service. Verify if the task and execution roles for the task definition have been successfully created in the console.


#### Backenk-flask ECS Task Definition for Fargate 

Using the provided [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/4da384125fa15b91e6852840738c225dfe00309a#diff-fce4cbfaaa6ae500dea2961ebd2e8395ff961a7a764b1cebc1f11325d50a2866) as a guide, create a Task Definition file  `aws/task-definitions/backend-flask.json`. Be sure to modify the values in the JSON file to match those of your AWS account.

##### Register Task Definition for Backend-flask:
```sh
ws ecs register-task-definition --cli-input-json file://aws/task-definitions/backend-flask.json
```

Navigate to the AWS Management Console and go to AWS ECS (Elastic Container Service). Check the Task Definitions section to verify if the task definition has been successfully created in the console.

![](assets/task-definition-backend-flask.png)

##### Security Group for Backend-flask Service

To obtain the DEFAULT_VPC_ID and DEFAULT_SUBNET_IDS required for creating a security group named `crud-srv-sg` with inbound rules for port `4567`, you can use the following AWS CLI commands:

```sh
export DEFAULT_VPC_ID=$(aws ec2 describe-vpcs \
--filters "Name=isDefault, Values=true" \
--query "Vpcs[0].VpcId" \
--output text)
echo $DEFAULT_VPC_ID

export DEFAULT_SUBNET_IDS=$(aws ec2 describe-subnets  \
 --filters Name=vpc-id,Values=$DEFAULT_VPC_ID \
 --query 'Subnets[*].SubnetId' \
 --output json | jq -r 'join(",")')
echo $DEFAULT_SUBNET_IDS
```

To create a security group named `crud-srv-sg` and allow inbound traffic on port `4567`, execute the following commands:

```sh
export CRUD_SERVICE_SG=$(aws ec2 create-security-group \
  --group-name "crud-srv-sg" \
  --description "Security group for Cruddur services on ECS" \
  --vpc-id $DEFAULT_VPC_ID \
  --query "GroupId" --output text)
echo $CRUD_SERVICE_SG

aws ec2 authorize-security-group-ingress \
  --group-id $CRUD_SERVICE_SG \
  --protocol tcp \
  --port 4567 \
  --cidr 0.0.0.0/0
```

Navigate to the AWS Management Console and select EC2 (Elastic Compute Cloud). Go to the Security Groups section to confirm if the security group, `crud-srv-sg`, was created successfully and if the inbound rules for port `4567` were set accordingly.

##### Create ECS Cluster Service for Backend-flask

using this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-a2eea4c74369eeb48e7b10271b7e8b62e4487c546a362ab3367656b4ed299099), create file in `aws/json/service-backend-flask`. Be sure to modify the security group id and subnets in the file to match those of your AWS account.

Execute this command to create a service:
```sh
aws ecs create-service --cli-input-json file://aws/json/service-backend-flask.json
```

In the AWS Management Console, navigate to ECS (Elastic Container Service) clusters. Locate the backend service and access the Service tab to verify if the service is running. Additionally, check the health check status to ensure that it is showing as healthy.

![](assets/healthy-backend-flask.png)


###### Connect to the backend-flask container by utilizing AWS Systems Manager Session Manager.

As seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-5e69de896a2f2b06791ac316dc95f94b7e0e3313e2fb66f80d2c367a215fa545) create a new file `backend-flask/bin/ecs/connect-to-service` and make it executable.

Install Sessions Manager plugin for Linux and access the ECS cluster via the CLI with the following commands:

```sh
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"

sudo dpkg -i session-manager-plugin.deb
```

To verify that it was successfully installed, run:  `session-manager-plugin`

Based on the provided [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/97fbe8a7f0f31fe7d8589afd7c7985a0c822fdaf#diff-370a022e48cb18faf98122794ffc5ce775b2606b09a9d1f80b71333425ec078e), make the necessary modifications to the `.gitpod.yml` file to ensure that AWS Systems Manager Session Manager is installed every time the environment is launched.

To connect to the container, execute the following command in the terminal:

```sh
./bin/ecs/connect-to-backend-service <task ARN ID>
```

Edit the inbound rule of the RDS instance security group to grants access to the `crud-srv-sg` security group, then run `./bin/db/test` to test RDS connection.

![](assets/service-test-connection.png)


### Application Load Balancer

To provision and configure an Application Load Balancer (ALB) and target groups via the AWS console, follow these steps:

  - Access the AWS Management Console and navigate to the EC2 service.
  - Choose "Load Balancers" from the sidebar menu and click on the "Create Load Balancer" button.
  - Configure the basic settings as follows:
    - Name: cruddur-alb
    - Scheme: Internet-facing
    - IP address type: IPv4
  - Configure the network mapping:
    - Choose the default VPC.
    - Select all availability zones.
  - Set up the security groups:
    - Create a new security group named cruddur-alb-sg.
  - Configure inbound rules as follows:
    - HTTP and HTTPS from anywhere.
    - Custom TCP rules for ports 4567 and 3000 from anywhere.
  - Edit the inbound rules of the security group crud-srv-sg:
    - Set the port source from cruddur-alb-sg.
    - Set the description of port 4567 as ALBbackend and port 3000 as ALBfrontend.
  - Configure listeners and routing:
    - Create an HTTP listener on port 4567 and associate it with a new target group named cruddur-backend-flask-tg.
    - Set the target type as IP addresses.
    - Configure the health check path as /api/health-check with a healthy threshold of 3.
    - Get the ARN of this target group to use in the aws/json/service-backend-flask.json file.
    - Add another HTTP listener on port 3000 and associate it with a new target group named cruddur-frontend-react-js.
    - No need to configure a health check for this target group.
    - Set the healthy threshold to 3.
    - Get the ARN of this target group to use in the aws/json/service-frontend-react-js.json file.
















