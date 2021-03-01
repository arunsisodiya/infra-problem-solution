ENV ?= dev
APPS_DIR ?= application
APPS=front-end quotes newsfeed
STATIC_ARCHIVE=static
IMAGE_TAG ?= v1
BUILD_DIR=build
DOCKER_HUB_USER ?= arunsingh1801

docker.build:
	@cd $(APPS_DIR) && $(MAKE) libs && $(MAKE) clean all
	@for APP in $(APPS); do docker build --no-cache -f Dockerfile --build-arg JAR_FILE=$(APPS_DIR)/$(BUILD_DIR)/$$APP.jar -t $$APP:$(IMAGE_TAG) .; done
	@docker build --no-cache -f Dockerfile_static --build-arg STATIC_ARCHIVE=$(APPS_DIR)/$(BUILD_DIR)/$(STATIC_ARCHIVE).tgz -t $(STATIC_ARCHIVE):$(IMAGE_TAG) .;

docker.push:
	@for APP in $(APPS); do docker tag $$APP:$(IMAGE_TAG) $(DOCKER_HUB_USER)/$$APP:$(IMAGE_TAG) && docker push $(DOCKER_HUB_USER)/$$APP:$(IMAGE_TAG); done
	@docker tag $(STATIC_ARCHIVE):$(IMAGE_TAG) $(DOCKER_HUB_USER)/$(STATIC_ARCHIVE):$(IMAGE_TAG) && docker push $(DOCKER_HUB_USER)/$(STATIC_ARCHIVE):$(IMAGE_TAG)

build_infra:
	@cd env-config/$(ENV) && terraform init && terraform plan -out=$(ENV)-output && terraform apply --auto-approve "$(ENV)-output"

destory.infra:
	@cd env-config/$(ENV) && terraform destroy -auto-approve

output:
	@cd env-config/$(ENV) && terraform output

config.application:
	@ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i env-config/$(ENV)/$(ENV)-inventory ansible/playbook.yml