#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# filename          : entrypoint.py
# description  : Script to build infrastructure and deploy application in cloud(AWS)
# author            : arun1801
# email             : btrack44@gmail.com
# date              : 2021/02/28
# version           : 0.01
# usage             : python3 entrypoint.py
# license           : -
# ==============================================================================
import os
import shutil
import subprocess
import sys

import git


class GitCheckout:
    """Class to checkout application code from repository"""

    def __init__(self, git_repo, git_branch, username, password, destination_dir):
        self.git_repo = git_repo
        self.git_branch = git_branch
        self.username = username
        self.password = password
        self.destination_dir = destination_dir

    def checkout(self):
        if self.username != "" and self.password != "":
            repo_url = "https://{0}:{1}@{3}".format(self.username, self.password, self.git_repo)
        else:
            repo_url = "https://{0}".format(self.git_repo)
        shutil.rmtree(self.destination_dir)
        git.Repo.clone_from(repo_url, self.destination_dir, branch=self.git_branch)


class TerraformCommands:
    """Class to build infrastructure in respective environment"""

    def __init__(self, environment):
        self.environment = environment

    def terraform_init(self):
        stdout = subprocess.run(["terraform", "init"], cwd="env-config/{0}/".format(self.environment))
        print(stdout)

    def terraform_plan(self):
        stdout = subprocess.run(["terraform", "plan"], cwd="env-config/{0}/".format(self.environment))
        print(stdout)

    def terraform_apply(self):
        stdout = subprocess.run(["terraform", "apply", "-auto-approve", "-refresh=false"],
                                cwd="env-config/{0}/".format(self.environment))
        print(stdout.stdout)
        # for line in stdout.stdout:
        #     if "instance_ip" in line:
        #         print(line)

    def terraform_destroy(self):
        stdout = subprocess.run(["terraform", "destroy"], cwd="env-config/{0}/".format(self.environment))
        print(stdout)


class DockerOperations:
    """Class for making docker image and pushing to ECR"""

    def __init__(self, region, registry_url, application_dir):
        self.region = region
        self.registry_url = registry_url
        self.application_dir = application_dir

    def docker_login(self):
        stdout = os.system(
            "aws ecr get-login-password --region {0} | docker login --username AWS "
            "--password-stdin {1}".format(self.region, self.registry_url))
        print(stdout)

    def docker_build(self):
        subprocess.run(["make", "libs"], cwd="{0}/".format(self.application_dir))
        subprocess.run(["make", "clean", "all"], cwd="{0}/".format(self.application_dir))
        for file in os.listdir("{0}/build/".format(self.application_dir)):
            if file.endswith(".jar"):
                os.system(
                    "aws ecr create-repository --repository-name {1} --image-scanning-configuration scanOnPush=true "
                    "--region {0}".format(self.region, file))
                os.system(
                    "docker build --no-cache --build-arg JAR_FILE={0}/build/{1} -t {1}:v1 .".format(
                        self.application_dir,
                        file))
                os.system("docker tag {0}:v1 {1}/{0}:v1".format(file, self.registry_url))
                os.system("docker push {1}/{0}:v1".format(file, self.registry_url))


def main():
    """Main method for entrypoint script"""
    repository = "github.com/ThoughtWorksInc/infra-problem"
    branch = "master"
    username = ""
    password = ""
    destination_dir = "application"
    git_checkout = GitCheckout(repository, branch, username, password, destination_dir)
    git_checkout.checkout()
    environment = "dev"
    terraform = TerraformCommands(environment)
    answer = input("Do you want to build infrastructure or destroy: ")
    if answer == "build":
        terraform.terraform_init()
        terraform.terraform_plan()
        terraform.terraform_apply()
    elif answer == "destroy":
        terraform.terraform_destroy()
        sys.exit(1)
    else:
        print("Please input correct answer")
        sys.exit(1)
    region = "eu-west-1"
    registry_url = "642710491613.dkr.ecr.eu-west-1.amazonaws.com"
    docker_operations = DockerOperations(region, registry_url, destination_dir)
    docker_operations.docker_login()
    docker_operations.docker_build()


if __name__ == "__main__":
    main()
