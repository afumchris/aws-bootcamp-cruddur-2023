# Week 8 — Serverless Image Processing

## CDK Setup

  - create a new folder `thumbing-serverless-cdk` to contain cdk dependencies and pieces we need.
  - cd into `thumbing-serverless-cdk` directory and Run the following commands:
      -  `npm install aws-cdk -g` to install aws cdk.
      -  `cdk init app --language typescript` to initialize the cdk application with all the files and folder we need for a typescript project as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/7e1155c4c155c4044c1fe0ac45956dc989a33427).
  - All our infrastructure will be defined in `thumbing-serverless-cdk/lib/thumbing-serverless-cdk-stack.ts` file
      - Edit the `lib/thumbing-serverless-cdk-stack.ts` file to create an S3 bucket and a Lambda function as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/7e1155c4c155c4044c1fe0ac45956dc989a33427#diff-6be534b5f75d78dfcb7e3e037c1d79a5012aa2c034e836b0b90e048fce60b831)
  - Create a `thumbing-serverless-cdk/.env` file and run this command `npm i dotenv` to intsall `dotenv` packages.
      - input the following env var in your `.env` file
   
       ```sh
       THUMBING_BUCKET_NAME="assets.your_domain_name"
       THUMBING_FUNCTION_PATH="/workspace/aws-bootcamp-cruddur-2023/aws/lambdas/process-images"
       THUMBING_S3_FOLDER_INPUT="avatars/original"
       THUMBING_S3_FOLDER_OUTPUT="avatars/processed"
       ```

  - Run the following commands:
      -  `cdk bootstrap "aws://account_id/your_aws_region"` to prepare your AWS account to use AWS CDK
      -  `cdk synth` to generate synthesized CloudFormation template for your CDK application.
      -  `cdk deploy` to deploy your CDK application and create AWS resources defined in your CDK code.
    


