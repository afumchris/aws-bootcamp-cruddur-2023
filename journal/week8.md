# Week 8 — Serverless Image Processing

## CDK Setup

  - create a new folder `thumbing-serverless-cdk` to contain cdk dependencies and pieces we need.
  - cd into `thumbing-serverless-cdk` directory and Run the following commands:
      -  `npm install aws-cdk -g` to install aws cdk.
      -  `cdk init app --language typescript` to initialize the cdk application with all the files and folder we need for a typescript project as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/7e1155c4c155c4044c1fe0ac45956dc989a33427).
  - All our infrastructure will be defined in `thumbing-serverless-cdk/lib/thumbing-serverless-cdk-stack.ts` file
      - Edit the `lib/thumbing-serverless-cdk-stack.ts` file to create an S3 bucket and a Lambda function as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/7e1155c4c155c4044c1fe0ac45956dc989a33427#diff-6be534b5f75d78dfcb7e3e037c1d79a5012aa2c034e836b0b90e048fce60b831)
  - Create a `thumbing-serverless-cdk/.env.example` file and run this command `npm i dotenv` to intsall `dotenv` packages.
      - input the following env var in your `.env.example` file
   
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
   

## Implement Serverless Pipeline

  - Edit the `.gitpod.yml` file as seen in this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-370a022e48cb18faf98122794ffc5ce775b2606b09a9d1f80b71333425ec078e) to:
     - Install the AWS CDK globally.
     - Copy the .env.example file and install npm dependencies in the thumbing-serverless-cdk directory ar runtime.

  - Edit the `thumbing-serverless-cdk/lib/thumbing-serverless-cdk-stack.ts` file as seen [here](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-6be534b5f75d78dfcb7e3e037c1d79a5012aa2c034e836b0b90e048fce60b831) to add logging for environment variables used in the CDK stack.

  - create a folder called `aws/lambdas/process-images`
     - Add an [`example.json`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-24c101c202492da94ce54387c595d61f2e12f49ddc5c7af9ff2fef9be895fc9c) file for testing Lambda event data.
     - Modify the Lambda function code [`index.js`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-849622b4b242ea3541407533ac2cdb116ec10fbf6e1d6d556feb5944eb532299) to process images and upload them to an S3 bucket.
     - Create a helper module [`s3-image-processing.js`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-40d8b09d181ff1a7d3c1b1f69f06d6015e074bf996803cd409c532548a43bd9c) for image processing functions.
     - Add a [`test.js`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-16ef85616d0f53b0b98e044b5824337e30dc405fd936d9dc48373ef8c69fd6dc) file to test the image processing functions.

  - Edit the `thumbing-serverless-cdk/.env.example` file  as seen [here](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/98183096220cb7cfc4c3f3812fb8243687d8ad79#diff-3a26f6bb4f45339b6822d778cdb41d2ff72716636966a7a43c48a6b0a057307f) to Update environment variables for the CDK stack.
  - cd into `aws/lambdas/process-images` folder and run the following commands
    ```
    npm init -y
    npm i sharp
    npm i @aws-sdk/client-s3
    ```

 - Add `node_modules` to the `.gitignore` file
 - cd into the `thumbing-serverless-cdk` folder and run the following commands
   ```
   cdk synth
   cdk deploy
   ```
 - 
   

    


