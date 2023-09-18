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
      -  `cdk destroy` to remove or destroy the AWS resources that were created by a CDK stack. 
   

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
 - Create a new script [`bin/serverless/build`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/eeda4d39bb380db117188f1edf1a34eeaff1b2d9#diff-0f12026649ff29f63cd9ff1a7ea11489c80a321fcb665f055d0983990cb619a6) to let the sharp dependency work in Lambda, make the script executable and run it.
 - Add scripts [`bin/serverless/upload`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/eeda4d39bb380db117188f1edf1a34eeaff1b2d9#diff-342b82f9713e6f09592c0103d336d9370a766105ae067ae6be17f81e21c1a408) and [`bin/serverless/clear`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/eeda4d39bb380db117188f1edf1a34eeaff1b2d9#diff-a715a421a7bf4283e6bffca08cffd4bf3bb1b221d95525ec78d854b75cb343c5) for managing S3 uploads and removals. Make sure to make them executable.
 - Create a folder `bin/serverless/files/data.jpg` and upload an image named `data.jpg`
 - Set your domain name as environment variable with the following command
   ```sh
   export DOMAIN_NAME=`your_domain_name`
   gp env DOMAIN_NAME=`your_domain_name`
   ```
   
 - Manually create S3 bucket(`assets.your_domain_name`) in AWS console, so the bucket can live outside the lifecycle of the stack.
 - modify [`thumbing-serverless-cdk/lib/thumbing-serverless-cdk-stack.ts`](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/eeda4d39bb380db117188f1edf1a34eeaff1b2d9#diff-6be534b5f75d78dfcb7e3e037c1d79a5012aa2c034e836b0b90e048fce60b831) to:
     - Modify bucket creation to support importing existing buckets.
     - Add Lambda event notifications for S3 objects and SNS topics.
     - Create policies for S3 bucket access and SNS topic publishing.
  
 - Run `cdk deploy` to create a change set and confirm if the bucket lived outside the lifecycle of the stack and then `cdk destroy`
 - Run `cdk deploy` to deploy your stack resources
 - Execute `./bin/serverless/upload` to upload `data.jpg` into `avatars/original/` folder in your S3 bucket.

Navigate to S3 bucket inyour AWS console to confirm if `data.jpg` was uploaded successfully.
   

 ## Serving Avatars via Cloudfront   


