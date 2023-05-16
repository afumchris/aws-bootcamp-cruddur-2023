# Week 1 — App Containerization

## Table of Contents

 - [Introduction](#introduction)
 - [Run the Applications Locally](#run-the-applications-locally)
 - [Containerize Backend and Frontend Applications](#containerize-backend-and-frontend-applications)
 - [Pushing Docker Image to Docker Hub](#pushing-docker-image-to-docker-hub)
 - [Container Orchestration with Docker Compose](#container-orchestration-with-docker-compose)
 - [Implementing Notifications](#implementing-notifications)
 - [Working with Databases](#working-with-databases)
 - [Container Security](#container-security)
 - [References](#references)

### Introduction

During the first week of the project, I focused on app containerization to improve the deployment and scalability of our applications. The primary goal was to utilize Docker for packaging our backend and frontend applications into containers, ensuring consistency across different environments.


### Run the Applications Locally

Launch your gitpod rnviroment and run the backend application locally. This step lets you to verify that the application is functioning correctly before proceeding with containerization

 - Backend Application

   Run the following commands to install and run flask
   ```
   cd backend-flask
   export FRONTEND_URL="*"
   export BACKEND_URL="*"
   python3 -m flask run --host=0.0.0.0 --port=4567
   ```
   
   Make sure to unlock port 4567 on the port tab and then open the link for port 4567 in your browser. After that, append "/api/activities/home" to the URL. By doing so, you should receive a JSON response as shown below. 
   
   ![](assets/backend-flask.png) 
### Containerize Backend and Frontend Applications

created Dockerfiles for each application, specifying the necessary dependencies and instructions to build the containers

  - #### Backend Application

    create a dockefile here: backend-flask/Dockerfile, copy the command below and paste it in your Dockerfile
    ```
    FROM python:3.10-slim-buster

    WORKDIR /backend-flask

    COPY requirements.txt requirements.txt
    RUN pip3 install -r requirements.txt

    COPY . .

    ENV FLASK_ENV=development

    EXPOSE ${PORT}
    CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
    ```

    Build and run the container with the following commands
    ```
    cd /workspace/aws-bootcamp-cruddur-2023
    docker build -t  backend-flask ./backend-flask
    docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
    ```
    
    Make sure to unlock port 4567 on the port tab and then open the link for port 4567 in your browser. After that, append "/api/activities/home" to the URL. By doing so, you should receive a JSON response like the one you got while running the backend application locally.
    
  - #### Frontend Application

    We have to run NPM Install before building the container since it needs to copy the contents of node_modules
    ```
    cd frontend-react-js
    npm i
    ```

    create a dockefile here: frontend-react-js/Dockerfile, copy the command below and paste it in your Dockerfile
    ```
    FROM node:16.18

    ENV PORT=3000

    COPY . /frontend-react-js
    WORKDIR /frontend-react-js
    RUN npm install
    EXPOSE ${PORT}
    CMD ["npm", "start"]
    ```
    
    Build and run the container with the following commands
    ```
    cd /workspace/aws-bootcamp-cruddur-2023
    docker build -t frontend-react-js ./frontend-react-js
    docker run --rm -p 3000:3000 -d frontend-react-js
    ```
    
    Make sure to unlock port 3000 on the port tab and then open the link for port 3000 in your browser, at this point you should see a preview of the frontend application.
    
    
    Unset the backend and frontend URL with these commands
    ```
    unset FRONTEND_URL="*"
    unset BACKEND_URL="*"
    ```
    
### Pushing Docker Image to Docker Hub

This step lets you to store and share containerized applications with other team members or deployment environments. 

   After successfully containerizing the applications, I pushed the backend image to my [public repository](https://hub.docker.com/repository/docker/afumchris/aws-bootcamp-cruddur-2023/general) on Docker Hub using the following commands
   ```
   docker login -u afumchris
   docker tag aws-bootcamp-cruddur-2023-backend-flask:latest afumchris/aws-bootcamp-cruddur-2023:backend-flask-week1
   docker push afumchris/aws-bootcamp-cruddur-2023:backend-flask-week1
   ```

### Container Orchestration with Docker Compose

To orchestrate multiple containers and simplify development environment setup, create docker-compose.yml at the root of the project

copy and paste the following command in your docker-compose.yml
```
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```
    
Now run docker compose up and unlock the ports 3000, 4567, open the link for 3000 in the browser, sign up and sign in as a new user with confirmation code of 1234 saved in the cookies.

### Implementing Notifications

