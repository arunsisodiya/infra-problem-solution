# Infra Problem Solution

This document helps to build an infrastructure using Iac(Infrastructure as code) deploy a micro-services based application in Cloud infrastructure.

- [ThoughtWorks - Infra Problem Solution](#thoughtworks---infra-problem-solution)
  - [Prerequisites](#prerequisites)
      - [Tools Compatibility Matrix](#tools-compatibility-matrix)
  - [Cloud provider configuration](#cloud-provider-configuration)
  - [Architecture Overview](#architecture-overview)
  - [Project Structure](#project-structure)
  - [Static Files configuration](#static-files-configuration)
  - [Building Infrastructure using Iac](#building-infrastructure-using-iac)
    - [Dependencies](#dependencies)
    - [Variables](#variables)
    - [Commands](#commands)
  - [Containerize the application and Push to docker hub](#containerize-the-application-and-push-to-docker-hub)
    - [Variables](#variables-1)
    - [Commands](#commands-1)
  - [Configure Swarm cluster and deploy application](#configure-swarm-cluster-and-deploy-application)
    - [Dependencies](#dependencies-1)
    - [Commands](#commands-2)
  - [Accessing the application via Load balancer](#accessing-the-application-via-load-balancer)
  - [TODO](#todo)
  - [Future work](#future-work)

## Prerequisites

To have a common development environment for all the users of this solution, following tools are expected on your computer:

#### Tools Compatibility Matrix

| Tool      | Version | Purpose                                                            | Download                                                                                   |
| --------- | ------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| Make      | 3.81    | Running make targets                                               | [Link](https://www.gnu.org/software/make/)                                                 |
| AWS CLI   | 2.1.28  | Run operations related to AWS resources such as pushing data to S3 | [Link](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)             |
| Terraform | > 0.12  | Bootstrapping the infrastructure (Iac)                             | [Link](https://www.terraform.io/)                                                          |
| Docker    | 20.10.2 | Containerize the application and Push to docker hub                | [Link](https://docs.docker.com/get-docker/)                                                |
| Ansible   | 2.10.6  | Performing configuration management tasks                          | [Link](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) |
| Python3   | > 3.6   | Running packages related to pip                                    | [Link](https://www.python.org/downloads/)                                                  |
| Pip       | 21.0.1  | Installing dependencies and tools such as Ansible                  | [Link](https://pip.pypa.io/en/stable/installing/)                                          |
| Leiningen | 2.9.5   | Running Clojure applications                                       | [Link](http://leiningen.org/)                                                              |

> Note- We are going to use **Docker swarm** as orchestration tool. There are many other orchestration tools available such as Kubernetes but for small applications we prefer to use Docker Swarm due to its simpler bootstrapping.

## Cloud provider configuration

Additional to the tools, we need some other configuration as well in form of setting environment variables for using cloud providers.

- Cloud provider used - [Amazon Web Services](https://aws.amazon.com/)

Before using the solution, we must have an AWS account with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` of a user with `arn:aws:iam::aws:policy/PowerUserAccess` policy. This policy provides full access to AWS services and resources, but does not allow management of Users and groups.

To create a user with PowerUserAccess policy, follow this tutorial - <https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-delegated-user.html>

Once IAM user has been created and we are ready with ACCESS credentials, we can set them as environment variables.

```bash
export AWS_ACCESS_KEY_ID=<ACCESS_KEY>
export AWS_SECRET_ACCESS_KEY=<ACCESS_SECRET>
```

_Note - There are different other mechanisms to inject **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY** but I am currently using the environment variables._

## Architecture Overview

In this section, we will look into the infrastructural point of view of the application.

![Cloud_Architecture](Hybrid%20Cloud%20Architecture.png)

Infrastructure of the application contains following components:

- `VPC` - A virtual private cloud created to host our application
- `Public Subnet` - This will only contain components which should be visible to outside world. This subnet contains `Elastic Load Balancer`, `Bastion host` & `Nat Gateway`
- `Private Subnet` - This will contain our real application and NGINX for reverse proxy
- `Network ACLs` - Network ACL have been applied on subnet level to prevent traffic from unknown sources
- `Bastion Host` - This host is required to perform multiple operations in our architecture such as connecting to EC2 in private subnet, run ansible playbook via SSH Forwarding
- `S3 bucket` - This will be hosting our static files such as css.
- `Security Groups` - They will define the security rules for the resources inside them
- `NAT Gateway` - This will give internet access to the EC2 machines present in private subnet. This is needed since few of our services want to fetch data from internet
- `Internet Gateway` - This is attached to VPC to provide internet access to VPC
- `Route Tables`- We are using route tables to define the routes for subnets

## Project Structure

Before building the infrastructure and running the application in cloud, lets understand the structure of the project -

```bash
├── ansible
│   ├── infra-problem
│   └── roles
│       ├── common
│       │   ├── defaults
│       │   ├── files
│       │   ├── handlers
│       │   ├── library
│       │   ├── meta
│       │   ├── tasks
│       │   ├── templates
│       │   └── vars
│       ├── stack
│       │   ├── defaults
│       │   ├── files
│       │   ├── handlers
│       │   ├── library
│       │   ├── meta
│       │   ├── tasks
│       │   ├── templates
│       │   └── vars
│       └── swarm
│           ├── defaults
│           ├── files
│           ├── handlers
│           ├── library
│           ├── meta
│           ├── tasks
│           ├── templates
│           └── vars
├── application
│  
├── env-config
│   ├── dev
│   └── test
└── terraform
    ├── docker-swarm
    │   └── ansible
    └── vpc
```

- ansible` - This directory contains the ansible roles configuration as well as stack which we want to deploy on our docker swarm cluster. To add new ansible roles, we can create them inside roles directory and import them in our **playbook.yml**.
- `application` - This directory contains our application which we want to containerize and deploy to cloud infrastructure.
- `env-config` - This directory contains the environment configuration. To add a new environment, we can create a new folder named as environment and create configuration variables in `main.tf`.
- `terraform` - This directory contains terraform modules which can be imported and based on the variables injected to module, infrastructure can be spin up. Similar to ansible roles, if we want to add a new module for our infrastructure, we can create them under terraform directory and import for specific environment.

## Static Files configuration

We are using AWS S3 bucket to serve static files. Infrastructure bootstrapping will take care of creating AWS S3 buckets and assigning policies to it.

During building and pushing the application to docker hub, we will push the static content to S3 bucket using aws cli.

## Building Infrastructure using Iac

### Dependencies

Before building the infrastructure, there is one dependency related to defining the ssh-key which will be used to communicate to the ec2 instances. This dependency can be removed in future. But in current solution, you have to [create a key pair in AWS console](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/getstarted-keypair.html) for the respective region of your environment and define the same in variables file of specific environment.

For example, In `env-config/dev/terraform.tfvars`, update the value of `key_pair` with the key that you have generated.

```ini
key_pair = "infra-dev"
```

### Variables

- `ENV` - Define the environment for which infrastructure need to be build

### Commands

To build the infrastructure for specific environment, we need to pass the folder name of environment in command line and run following command from the root directory of the project -

```bash
make build.infra ENV=<env_folder_name>
```

If we want to build the infrastructure for dev, run following command

```bash
make build.infra ENV=dev
```

If you don't pass any value to env variable then by default script will take `dev` as value for environment.

## Containerize the application and Push to docker hub

In this section, we will build the application and containerize it. Since we will be pushing our application to cloud infrastructure, we will need a docker repository to access the docker images of applications.

Currently, I am using a docker hub as solution which can be replaced with private repositories such as [AWS ECR](https://aws.amazon.com/ecr/). Docker Hub is only for demo purpose.

> Note: To use docker hub on your machine, you might need to login with your account. Please follow [this](https://ropenscilabs.github.io/r-docker-tutorial/04-Dockerhub.html) tutorial to login via CLI.

### Variables

- `DOCKER_HUB_USER` - Define the docker hub username to use your own docker hub repository. Defaults to `arunsingh1801`
- `IMAGE_TAG` - Define the image tag for your docker image. Defaults to `v1`

### Commands

To build the docker image, run the following command -

```bash
make app.build IMAGE_TAG=<image_tag>

e.g. make app.build IMAGE_TAG=v1
```

To push the application docker images to docker hub, run the following command -

```bash
make app.push DOCKER_HUB_USER=<repo_name> IMAGE_TAG=<image_tag>

e.g. make app.push DOCKER_HUB_USER=arunsingh1801 IMAGE_TAG=v1
```

## Configure Swarm cluster and deploy application

In this section, we will create a swarm cluster and deploy our application to it.
To achieve this, we will use `Ansible` as configuration management tool and configure our environment.

### Dependencies

Since we have created a infrastructure where our machines are in Private Subnet and can only be accessible via `Bastion Host`, we have to use SSH Proxy forwarding.
A full tutorial can be found here - <https://blog.scottlowe.org/2015/12/24/running-ansible-through-ssh-bastion-host/>

For the current solution, I have already generated ansible inventory file in such a way that it will enable Proxy forwarding. But we have to add our SSH key to Authentication agent on our machine to use SSO and finally update our inventory file to use the correct location of our pem file.

To sum up all the operations mentioned above, I have already developed a script named as `ssh_operations.sh` which will take command line options and perform all the operations. Run the script in following manner -

```bash
bash ssh_operations.sh <ENV_NAME> <LOCATION_OF_PEM_FILE>

e.g. bash ssh_operations.sh dev ~/Downloads/infra-dev.pem
```

This script will perform two major operations -

- Use `ssh-add` utility to add your private_key file into Authentication agent
- Update the ansible inventory file generated under `env-config/<env>/` with the correct key for ProxyCommand

### Commands

If you have reached this step successfully, that means we are ready to use our bastion host as Proxy to connect to our private ec2 instances and run `ansible-playbooks`.

Try to run the following command to test if we are getting some response from our ec2 instances.

`ANSIBLE_HOST_KEY_CHECKING=False ansible -i env-config/dev/dev-inventory -m ping managers`

You should get a output like this -

```json
ip-10-0-1-248.eu-west-1.compute.internal | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

Now we have to validate our ansible stack configuration and we are good with deploying Docker Swarm cluster to AWS and run our application in cloud.

- **Docker Image Validation**:

  To validate that, go to `ansible/infra-problem/` and check `infra-compose.yml` to use the correct docker image for all the services. Please correct the username for the images being used by the services,

  ```yaml
  front-end:
    image: "</front-end:v2"
  ```

  Replace `arunsingh1801` with your docker hub username

- **Docker network subnet validate**:

  Since we are running our docker swarm in the private subnet so we need to configure our `overlay` network to use the same subnet CIDR. You can see this configuration in `ansible/infra-problem/common-compose.yml`. You can get the value of subnet from `main.tf` of specific environment. e.g. from `env-config/dev/main.tf` we can see the value of private subnet,

  ```ini
  private_subnets = ["10.0.1.0/24"]
  ```

  ```yaml
  networks:
  infra-network:
    driver: overlay
    ipam:
      config:
        - subnet: 10.0.1.0/24
  ```

To configure docker swarm and deploy the application to stack, run the following command -

```bash
make config.application ENV=<environment_name>

e.g. make config.application ENV=dev
```

> Note: During ansible playbook run, sometimes you might get below error -

```yaml
fatal: [ip-10-0-1-248.eu-west-1.compute.internal]: FAILED! => {"changed": false, "err": "Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.24/info: dial unix /var/run/docker.sock: connect: permission denied\n", "msg": "docker stack up deploy command failed", "out": "", "rc": 1, "stderr": "Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.24/info: dial unix /var/run/docker.sock: connect: permission denied\n", "stderr_lines": ["Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.24/info: dial unix /var/run/docker.sock: connect: permission denied"], "stdout": "", "stdout_lines": []}
```

This just depicts that docker on the system is not fully ready and you have to wait few minutes to get everything ready and then run the playbook again.

In the successful output, you might see something like this-

```yaml
ip-10-0-1-211.eu-west-1.compute.internal: ok=11   changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
ip-10-0-1-234.eu-west-1.compute.internal: ok=11   changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
ip-10-0-1-248.eu-west-1.compute.internal: ok=19   changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

## Accessing the application via Load balancer

We have configured two layers of load balancers:

- `NGINX (Private)` - This is configured at docker swarm level to work as proxy server and redirects our requests to internal services.
- `Elastic Load Balancer (Public)` - This is configured in public subnet which will be accessible to users and will take care of two major things:
  - Load balancing between the instances present in our Docker swarm cluster
  - Perform health check via `/ping` uri and inform us about the health of application.

To access the application which we have deployed in previous step, Please access the public dns name of ELB which we can get from terraform output. Run the following command:

```bash
make output
```

Output should look like this:

```json
bastion_instance_ip = "52.208.14.122"
elb_dns_name = "infra-elb-dev-1660110340.eu-west-1.elb.amazonaws.com"
private_subnets_id = "subnet-0090e001cc5748b5f"
public_subnets_id = "subnet-095a213274341c5a3"
vpc_cidr_block = "10.0.0.0/16"
vpc_id = "vpc-0bc6f1a702f231bf1"

```

Copy the `elb_dns_name` and access the application. If your url is not working, please wait for few minutes since ELB will wait until at least one of the instance is healthy.

## TODO

- [ ] Add HTTPS support and communicate over secure protocol
- [ ] Add support for auto generation of SSH key pair
- [ ] Use private repository (ECR) support for docker images
- [ ] Use Terraform remote state storage for delegation, locking and teamwork

## Future work

- [Future work [Concept]](Future-work.md)
