# Week 5 — DynamoDB and Serverless Caching

## Table of Contents:

  - [Introduction](#introduction)
  - [Data Modelling](#data-modelling)
  - [Setting up DynamoDB Local](#setting-up-dynamodb-local)
  - [DynamoDB Utility Scripts](#dynamodb-utility-scripts)
  - [Implement Conversations with DynamoDB Local](#implement-conversations-with-dynamodb-local)
  - Implement DynamoDB Stream with AWS Lambda
  - References

### Introduction

This week, we explored the implementation of DynamoDB, a fully managed NoSQL database service provided by Amazon Web Services (AWS). DynamoDB offers scalability, reliability, and low latency, making it suitable for various applications. We covered the process of setting up DynamoDB locally, data modeling techniques, utility scripts for managing DynamoDB, and implementing conversations and DynamoDB streams using AWS Lambda.

### Data Modelling

In this particular scenario, we employ the Single Table Design approach to store all related data. By adopting this technique, we can achieve efficient and reliable data retrieval. Storing similar items within the same table also helps to simplify the application's complexity, leading to improved performance.

#### Access Patterns:

  1. Pattern A - Displaying Messages:
This pattern allows users to view a list of messages belonging to a specific message group. The messages are typically presented in descending order, providing users with an overview of their conversations.
  2. Pattern B - List of Conversations (All Direct Messages):
This access pattern provides users with a comprehensive list of message groups, giving them an overview of all their direct message conversations. Users can quickly access and navigate through different message groups, facilitating efficient communication.
  3. Pattern C - Creating a New Message in a New Message Group:
With this pattern, users can initiate a new conversation by creating a new message in a previously nonexistent message group. This functionality facilitates the start of fresh discussions between users.
  4. Pattern D - Creating a New Message in an Existing Message Group:
This pattern allows users to add a new message to an existing message group, thereby extending the ongoing conversation with other users.

To address the specific access patterns, our DynamoDB table requires the implementation of the following code to distinguish between different types of data queries and manipulations:

```python
my_message_group = {
    'pk': {'S': f"GRP#{my_user_uuid}"},
    'sk': {'S': last_message_at},
    'message_group_uuid': {'S': message_group_uuid},
    'message': {'S': message},
    'user_uuid': {'S': other_user_uuid},
    'user_display_name': {'S': other_user_display_name},
    'user_handle':  {'S': other_user_handle}
}

other_message_group = {
    'pk': {'S': f"GRP#{other_user_uuid}"},
    'sk': {'S': last_message_at},
    'message_group_uuid': {'S': message_group_uuid},
    'message': {'S': message},
    'user_uuid': {'S': my_user_uuid},
    'user_display_name': {'S': my_user_display_name},
    'user_handle':  {'S': my_user_handle}
}

message = {
    'pk':   {'S': f"MSG#{message_group_uuid}"},
    'sk':   {'S': created_at},
    'message': {'S': message},
    'message_uuid': {'S': message_uuid},
    'user_uuid': {'S': my_user_uuid},
    'user_display_name': {'S': my_user_display_name},
    'user_handle': {'S': my_user_handle}
}
```

### Setting up DynamoDB Local

Set `AWS_COGNITO_USER_POOL_ID` as enviroment variable using this command:

```sh
export AWS_COGNITO_USER_POOL_ID="your AWS_COGNITO_USER_POOL_ID"
gp env AWS_COGNITO_USER_POOL_ID="your AWS_COGNITO_USER_POOL_ID"
```

using this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/b54210c4c8a4a10a0e4b90ba61b57347f864b42b) make the following changes:

  - `.gitpod.yml`: Added a new task named "flask" that changes the directory to "backend-flask" and installs the project dependencies by running pip install -r requirements.txt.
  - `backend-flask/bin/cognito/list-users`: This script lists the users in the Cognito user pool associated with the application.
It retrieves the AWS_COGNITO_USER_POOL_ID environment variable and uses the boto3 library to interact with Cognito.
The script prints the list of users and creates a dictionary mapping the user handle to the Cognito sub (user identifier).
  - `backend-flask/bin/db/setup`: modified it to run a Python script `update_cognito_user_ids` to update the Cognito user IDs in the database.
  - `backend-flask/bin/db/update_cognito_user_ids`: This Python script updates the Cognito user IDs in the database for existing users.
  - `backend-flask/db/seed.sql`: Modified the script to add another user.
  - `docker-compose.yml`: Updated the CONNECTION_URL environment variable for the backend-flask service to use the specified PostgreSQL connection URL.

Run `docker compose up` with the following commands as shown in the screenshot below for confirmation:

![](/journal/dynamodb-local.png)

![](assets/list-users.png)





### DynamoDB Utility Scripts

Create the following utility scripts using this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/e2096e9a35e09418df10872e102855ea19041fb5) and this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/a062d274bd00347f92e668855212516cdb66a2af) to aid in managing and administering DynamoDB:

  - `backend-flask/bin/ddb/schema-load`: creates a table named "cruddur-messages," either on DynamoDB local or on the AWS platform for prod.
  - `backend-flask/bin/ddb/drop`: drops a DynamoDB table.
  - `backend-flask/bin/ddb/list-tables`: lists DynamoDB tables created.
  - `backend-flask/bin/ddb/patterns/get-conversation`: queries a DynamoDB table for a conversation.
  - `backend-flask/bin/ddb/patterns/list-conversations`: list content related to querying a DynamoDB table for conversations.
  - `backend-flask/bin/ddb/scan`: scans all items in a DynamoDB table.
  - `backend-flask/bin/ddb/seed`: loads the seed data into the dynamoDB table.
  - Modified the file `backend-flask/db/seed.sql` to include additional insert statements.
  - Modified the file `backend-flask/lib/db.py` to add new functions and modify existing ones related to printing SQL statements, querying JSON objects, and querying a single value.


schema-load and list-tables:

![](assets/list-tables.png)

seed data:

![](assets/ddb-seed.png)

scanning items:

![](assets/ddb-scan.png)

get-conversation:

![](assets/get-conversation.png)

list-conversations:

![](assets/list-conversations.png)



### Implement Conversations with DynamoDB Local



