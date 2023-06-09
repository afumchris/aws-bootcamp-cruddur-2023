# Week 4 — Postgres and RDS

## Table of Contents

- [Introduction](#introduction)
- [Bash Scripts and SQL for Postgres Operations](#bash-scripts-and-sql-for-postgres-operations)
- [RDS DB Instance on AWS](#rds-db-instance-on-aws)
- [Implementing a Postgres Client](#implementing-a-postgres-client)
- [AWS Lambda for Cognito Post Confirmation](#aws-lambda-for-cognito-post-confirmation)
- [Activity Creation](#activity-creation)
- [References](#references)

### Introduction

During the fourth week of the project, our focus was on working with Postgres and RDS (Relational Database Service). We aimed to enhance our understanding of Postgres operations, set up an RDS DB instance on AWS, implement a Postgres client, utilize AWS Lambda for Cognito Post Confirmation, and create activities within Cruddur.

### Bash Scripts and SQL for Postgres Operations

 We focused on the utilization of Bash scripts and SQL for executing different operations in Postgres. Our objective was to automate tasks like creating databases, tables, inserting data, and querying by leveraging the capabilities of Bash scripts. Furthermore, we examined the effectiveness of SQL statements in efficiently manipulating and retrieving data from our Postgres database.
 
 In order to work with the local Postgres, it is necessary to define the CONNECTION_URL. This can be achieved by exporting the variable using the following command:
 
```sh
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
```
 
 [This commits](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/ff938a80c2a9b3dd2ea86ba568985939729a320b) include changes to various scripts and SQL files. To make the script executable, run `chmod u+x <PATH_OF_SCRIPT>`. Here is a brief overview of the changes and their functionalities:

   - `db-connect`: Added a script to establish a connection to the PostgreSQL database. Determines the appropriate connection URL based on the environment (prod or local).Executes the psql command to establish the connection.
   - `db-create`: Added a script to create a new PostgreSQL database named `cruddur`. Uses the connection URL to connect to the PostgreSQL server. Executes the SQL command `create database cruddur` to create the database.
   - `db-drop`: Added a script to drop the PostgreSQL database named `cruddur`. Uses the connection URL to connect to the PostgreSQL server. Executes the SQL command `drop database cruddur` to drop the database.
   - `db-schema-load`: Added a script to load the database schema from the file `db/schema.sql`. Determines the appropriate connection URL based on the environment. Uses the `psql` command to execute the SQL script and load the schema.
   - `db-seed`: Added a script to seed the PostgreSQL database with initial data from `db/seed.sql`. Connects to the PostgreSQL server using the provided connection URL. Executes the SQL script to insert data into the users and activities tables.
   - `db-sessions`: Added a script to retrieve information about active sessions in the PostgreSQL database. Determines the appropriate connection URL based on the environment. Executes the SQL command to query the pg_stat_activity view and fetch session information.
   - `db-setup`: Added a script to set up the PostgreSQL database by executing a series of scripts in the correct order. Sources the `db-drop`, `db-create`, `db-schema-load`, and `db-seed` scripts using the source command.
   - `db/schema.sql`: Modified the SQL schema file to define the structure of the users and activities tables. Added columns for UUID, display name, handle, cognito user ID, timestamps, and other relevant fields.
   - `db/seed.sql`: Modified the SQL seed data file to insert initial data into the users and activities tables. Includes records for users with display names, handles, and mock Cognito user IDs.Includes an example activity record with a message and expiration timestamp.

Run `docker compose up` and the following commands `./bin/db-create`, `./bin/db-schema-load`, `./bin/db-seed` and `./bin/db-connect` to connect to the local database.

![](assets/dev-psql.png)

### RDS DB Instance on AWS

We created an RDS DB instance on AWS. We followed the AWS documentation and guidelines to create a PostgreSQL database instance with the desired specifications, such as storage capacity, instance type, and security configurations. We ensured proper network connectivity and access control for our RDS instance.

Utilize the command line with the following commands to create a RDS database instance:

```sh
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username cruddurroot \
  --master-user-password <PASSWORD> \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
  ```
  
To export and set the production connection URL for the RDS DB instance, the following commands were executed:
  
```sh
export PROD_CONNECTION_URL="postgresql://<master-username>:<master-user-password>@<aws-rds-endpoint>:<port>/<db-name>"
gp env PROD_CONNECTION_URL="postgresql://<master-username>:<master-user-password>@<aws-rds-endpoint>:<port>/<db-name>"
```

To enable remote connectivity from your Gitpod workspace to the RDS instance, you'll need to modify the inbound rules of the VPC security groups associated with the RDS instance. Specifically, you should allow Gitpod's IP address to access port 5432 for PostgreSQL. You can retrieve Gitpod's IP address by executing the command `curl ifconfig.me`.

Once you have the IP address, you can follow these steps in the AWS console:

  - Navigate to the AWS console.
  - Locate the security group associated with your RDS instance.
  - Edit the inbound rules for that security group.
  - Add a new rule that allows inbound traffic from Gitpod's IP address to port 5432.
  - Save the changes.


After making these modifications, your AWS console should resemble the screenshot provided below as confirmation that the inbound rules have been successfully updated.

![](assets/sg-rule.png)

To ensure that the current IP of the Gitpod workspace can always connect to the RDS instance remotely, you can use the following command line, which dynamically fetches the IP and updates the inbound rule:

```sh
export DB_SG_ID="YOUR_ID_FOR_THE_SECURITY_GROUP"
gp env DB_SG_ID="YOUR_ID_FOR_THE_SECURITY_GROUP"
export DB_SG_RULE_ID="YOUR_ID_FOR_THE_SECURITY_GROUP_RULE"
gp env DB_SG_RULE_ID="YOUR_ID_FOR_THE_SECURITY_GROUP_RULE"

aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```

Update `gitpod.yml` and create a new file `backend-flask/bin/rds-update-sg-rule` for the security group rules of the RDS instance to automatically updated whenever the Gitpod workspace is started using this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/38267c9ce3790dc44f51bc1520b7f2178d50f0ba)


### Implementing a Postgres Client

In this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/7c79d53e9b4271cfe568130c684d02a1b1362635), several changes were made to replace the mock data on the home page with data queried from the database using SQL. This was achieved by implementing a PostgreSQL client for Python with a connection pool. Here's an overview of the steps involved:

   - Add the following dependencies to the `backend-flask/requirements.txt` file `psycopg[binary]` and `psycopg[pool]`. These dependencies will allow us to use the psycopg2 library for interacting with PostgreSQL.
   - Set the CONNECTION_URL environment variable in the `docker-compose.yml` file for the `backend-flask` application. This configuration will ensure that the application connects to the PostgreSQL database using the specified URL:

```sh
CONNECTION_URL: "postgresql://postgres:password@db:5432/cruddur"
```

   - Create the `backend-flask/lib/db.py` file to define the DB object and connection pool. This file will contain the necessary code to establish a connection pool using psycopg2.
   - Replace the mock endpoint in `backend-flask/services/home_activities.py` with a real API call. Instead of using mock data, this updated code will execute SQL queries against the database using the psycopg2 library to fetch the required activities for the `home page`.

After running `docker-compose up`, you will observe that the home page displays the activities specified in the `backend-flask/db/seed.sql` file, rather than the previous mock data. This change confirms that the application is now fetching data from the PostgreSQL database.

![](/journal/dev-query.png)

### AWS Lambda for Cognito Post Confirmation

We explored AWS Lambda for Cognito Post Confirmation, you will need to modify the user signup process as shown in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/3081cb032d9d4215c023eebea0a6e4e1390a870b) to insert the newly signed-up user into the users table in the RDS database.

Here are the changes made to the specified files:

  - `aws/lambdas/cruddur-post-confirmation.py`: Added a new Lambda function lambda_handler that handles the post-confirmation event.
  - `backend-flask/db/schema.sql`: Modified the public.users table schema by adding the email column.
  - `docker-compose.yml`: Modified the `CONNECTION_URL` environment variable to use the `${PROD_CONNECTION_URL}` variable.

Create a lambda function with the following configurations:

  - Sign in to the AWS Management Console and open the AWS Lambda service.
  - Click on Create function to create a new Lambda function.
  - Choose the `Author from scratch` option.
  - Provide a name for your Lambda function, such as `cruddur-post-confirmation`.
  - Choose Python 3.8 as the runtime environment for your Lambda function.
  - Create function
  - For code source, copy the code as seen in `aws/lambdas/cruddur-post-confirrmation.py` and deploy.
  - In the Configuration tab of the Lambda function console, add environment variable for the database. For Key use `CONNECTION_URL`,  and for Value use `postgresql://<master-username>:<master-user-password>@<aws-rds-endpoint>:<port>/<db-name>`
  - By referencing the provided [link](https://github.com/jetbridge/psycopg2-lambda-layer), Add a Layer for psycopg2 by specifying an appropriate ARN. In my particular case, I utilized the ARN: `arn:aws:lambda:us-east-1:898466741470:layer:psycopg2-py38:2`
  - In the configurations tab of AWS Lambda, grant permissions to the execution role by creating a policy named `AWSLambdaVPCAccessExecutionRole` in the IAM service's 'Policies' section. This policy will define the required permissions for accessing EC2 resources:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
}
```

![](assets/roles.png)


  - In the configurations tab of AWS Lambda, you can edit the VPC settings to establish a connection between Lambda and the RDS instance within a VPC. This allows Lambda to securely access the RDS instance. The resulting page will display the VPC configuration settings, as shown in the provided screenshot


![](/journal/vpc-lambda.png)


In Amazon Cognito's `cruddur-user-pool`, configure a Lambda trigger for the sign-up post confirmation event. Assign the Lambda function `cruddur-post-confirmation` to the trigger. Delete the existing user to allow signing up again and verify if the user is inserted into the RDS instance's users table.


![](assets/trigger.png)

Run `docker compose up` and the following command `./bin/db-schema-load prod`, and `./bin/db-connect prod` to connect to the prod database.

![](assets/prod-conn.png)

To review the logs for the Lambda function "cruddur-post-confirmation" at CloudWatch, follow these steps:
  - Access the CloudWatch service in the AWS Management Console.
  - Navigate to `Log groups` and search for the log group named `/aws/lambda/cruddur-post-confirmation`.
  - Click on the log group to view the logs associated with the Lambda function.

![](assets/logs.png)


### Activity Creation

We worked on implementing the ability to create activities. These involved SQL statements for creating and retrieving activities, improvements in SQL query formatting and JSON handling, and updates to service methods for activity creation and retrieval

Using this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/8b0181aa990855d8a49bf8112925304daa771d6b) and this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/542f655ced297b6d07658a7f2a689e098403a3f1), several changes were made to the files:

  - `backend-flask/db/sql/activities/create.sql`: Added an SQL statement to insert a new activity into the `public.activities` table, including parameters for `handle`, `message`, and `expires_at`.
  - `backend-flask/db/sql/activities/home.sql`: Added an SQL statement to retrieve a list of activities from the `public.activities` table, including joins with the `public.users` table and ordering by `created_at` in descending order.
  - `backend-flask/db/sql/activities/object.sql`: Modified the SQL statement to retrieve a single activity from the `public.activities` table based on the provided `uuid`, including joins with the `public.users` table.
  - `backend-flask/lib/db.py`: Added `query_wrap_object` and `query_wrap_array` methods to wrap SQL templates and return JSON objects or arrays, respectively. Updated existing methods to use the new wrapping functions.
  - `backend-flask/services/create_activity.py`: Added the `CreateActivity` class with the `run` method. The `run` method creates a new activity by calling the `create_activity` method and returns a model containing the activity data.
  - `backend-flask/services/home_activities.py`: Updated import statements and modified the `run` method to use the `db` object. Updated the SQL statement and removed print statements.
  - `backend-flask/app.p`y: Updated the `data_activities` route to retrieve the `user_handle` from the request's JSON payload instead of using a hardcoded value.
  - `frontend-react-js/src/components/ActivityForm.js`: Updated the `body` of the POST request to include the `user_handle` retrieved from the `props` instead of a hardcoded value.
  - `frontend-react-js/src/pages/HomeFeedPage.js`: Updated the `ActivityForm` component's `user_handle` prop to be passed the `user` object instead of a specific property (`handle`).


Run `docker compose up`, signin and create activities as shown bellow.

![](assets/activity.png)

To verify the data inserted into the `activities` table after creating activities, Run the command `./bin/db-connect prod` to connect to the production database.

![](assets/create.png)

### References

  - AWS Documentation [link](https://docs.aws.amazon.com/)
  - Postgres Official Documentation [link](https://www.postgresql.org/docs/)
  - AWS Lambda Developer Guide [link](https://docs.aws.amazon.com/lambda/)



