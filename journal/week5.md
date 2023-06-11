# Week 5 — DynamoDB and Serverless Caching

## Table of Contents:

  - [Introduction](#introduction)
  - [Data Modelling](#data-modelling)
  - [Setting up DynamoDB Local](#setting-up-dynamodb-local)
  - DynamoDB Utility Scripts
  - Implement Conversations with DynamoDB Local
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








