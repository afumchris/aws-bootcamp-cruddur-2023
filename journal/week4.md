# Week 4 — Postgres and RDS

## Table of Contents

- [Introduction](#introduction)
- [Bash Scripts and SQL for Postgres Operations](#bash-scripts-and-sql-for-postgres-operations)
- [RDS DB Instance on AWS](#rds-db-instance-on-aws)
- [Implementing a Postgres Client](#implementing-a-postgres-client)
- AWS Lambda for Cognito Post Confirmation
- Activity Creation
- References

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

   - `db-connect`: Added a script to establish a connection to the PostgreSQL database. Determines the appropriate connection URL based on the environment (prod or default).Executes the psql command to establish the connection.
   - `db-create`: Added a script to create a new PostgreSQL database named `cruddur`. Uses the connection URL to connect to the PostgreSQL server. Executes the SQL command `create database cruddur` to create the database.
   - `db-drop`: Added a script to drop the PostgreSQL database named `cruddur`. Uses the connection URL to connect to the PostgreSQL server. Executes the SQL command `drop database cruddur` to drop the database.
   - `db-schema-load`: Added a script to load the database schema from the file `db/schema.sql`. Determines the appropriate connection URL based on the environment. Uses the `psql` command to execute the SQL script and load the schema.
   - `db-seed`: Added a script to seed the PostgreSQL database with initial data from `db/seed.sql`. Connects to the PostgreSQL server using the provided connection URL. Executes the SQL script to insert data into the users and activities tables.
   - `db-sessions`: Added a script to retrieve information about active sessions in the PostgreSQL database. Determines the appropriate connection URL based on the environment. Executes the SQL command to query the pg_stat_activity view and fetch session information.
   - `db-setup`: Added a script to set up the PostgreSQL database by executing a series of scripts in the correct order. Sources the `db-drop`, `db-create`, `db-schema-load`, and `db-seed` scripts using the source command.
   - `db/schema.sql`: Modified the SQL schema file to define the structure of the users and activities tables. Added columns for UUID, display name, handle, cognito user ID, timestamps, and other relevant fields.
   - `db/seed.sql`: Modified the SQL seed data file to insert initial data into the users and activities tables. Includes records for users with display names, handles, and mock Cognito user IDs.Includes an example activity record with a message and expiration timestamp.

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
