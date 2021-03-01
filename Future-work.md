# Future work [Concept]

- [Future work [Concept]](#future-work--concept-)
  - [Continuos Delivery Pipeline Approach](#continuos-delivery-pipeline-approach)
  - [New Environment Bootstrapping](#new-environment-bootstrapping)
  
## Continuos Delivery Pipeline Approach

To extend the solution for continuous delivery pipelines and adding more environments, we can follow below approach-

- Since we are using a generic approach for building the infrastructure and deploying the application to cluster, we can sum up those steps and create deployment pipelines which can have following steps:

  ![Proposed Pipeline](Pipeline.png)

  - `Build Infrastructure` - Bootstrap the infrastructure with the variables configured for the specific environment. Either we can take environment as user input when running the pipeline or we can use branching strategy to decide the environment
  - `Build Application` - Build the application using respective tool
  - `Test Application` - Run the test cases (unit tests, integration tests)
    for the application
  - `Vulnerability Scanning` - Stage to check the potential threats in the code. We can use third party scanners as well e.g. WhiteSource
  - `SonarQube scan` - Stage to check the code quality and other issues with the code using quality gates
  - `Application Containerization` - Containerize the application with its dependencies
  - `Push to Container Repository` - Push the containerized application to the container registry. This can include pushing to private repositories. Access for private repositories can be configured either in CI/CD tool or in pipeline
  - `Static file upload` - A stage parallel to pushing to container registry which copy the static files to respective location e.g. to S3 bucket
  - `Bootstrap Swarm and Deploy Application` - This stage will bootstrap the swarm cluster and deploy the application stack in it
  - `Health Check` - This stage can be used to validate if the application is deployed properly

> To avoid the downtime of application, we can use a zero downtime deployment strategy such as `blue-green deployment`

## New Environment Bootstrapping

To bootstrap a new environment with the help of provided solution, we can follow below approach

- Create a new directory with the environment name under `env-config`
- Put configuration details of the specific environment in `main.tf` and configure values for variables in `terraform.tfvars`
- If we want to add some more features to our infrastructure, we can add modules in `terraform` directory and import them in `main.tf`. This makes the whole configuration modular and independent with each other
- Finally we can create our stack definition under `ansible/<stack_name>` and pass them in `playbook,yml` as vars

  ```yaml
      - role: stack
        vars:
          stack_name: infra-problem
  ```
  