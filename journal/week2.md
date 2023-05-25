# Week 2 — Distributed Tracing

## Table of Contents:

- [Introduction](#introduction)
- [Honeycomb Integration](#honeycomb-integration)
- AWS X-Ray Implementation
- AWS CloudWatch Log Management
- References

### Introduction

During the second week of our project, we focused on implementing distributed tracing to enhance the observability and performance of our system. This involved integrating various tools and services to capture and analyze trace data.

### Honeycomb Integration

Integrate Honeycomb in the Backend Application to provide tracing capabilities that enable us to gather and analyze trace data.

- Create a new environment called "bootcamp" on the [Honeycomb website](https://www.honeycomb.io/) and obtain the API key associated with it.

- Use the following commands to set the Honeycomb API Key as an environment variable

```sh
  
    export HONEYCOMB_API_KEY="<your API key>"
    gp env HONEYCOMB_API_KEY="<your API key>"
 ```
    
- Utilize this [commit](https://github.com/afumchris/aws-bootcamp-cruddur-2023/commit/affcbd358a33882965e15d515dd269da3e87903f) to implement the following modifications in order to instrument Honeycomb:

  - Open the backend-flask/requirements.txt file and add the required dependencies for OpenTelemetry.

  - In the docker-compose.yml file, add the following environment variables for the OpenTelemetry exporter and tracing configuration.

  - Open the backend-flask/app.py file and make the following changes:

      - Import the necessary modules and services related to distributed tracing.
      - Initialize tracing and an exporter to send trace data to Honeycomb.
      - Instrument the Flask application using the OpenTelemetry Flask Instrumentor.
      - Instrument outgoing requests using the OpenTelemetry Requests Instrumentor.


Execute the command "docker-compose up" to run the Docker Compose configuration, ensure that port 4567 is unlocked by accessing the ports tab in the respective settings, open the link corresponding to port 4567 in your preferred web browser, once the page loads, append "/api/activities/home" to the URL. To view the traces, navigate to the Honeycomb website and refer to the provided screenshot for guidance.

![](assets/trace.png)


    
