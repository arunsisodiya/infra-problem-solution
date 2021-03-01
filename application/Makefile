BUILD_DIR=build
APPS=front-end quotes newsfeed
LIBS=common-utils
STATIC_BASE=front-end/public
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
INSTALL_TARGETS=$(addsuffix .install, $(LIBS))
APP_JARS=$(addprefix $(BUILD_DIR)/, $(addsuffix .jar, $(APPS)))

all: $(BUILD_DIR) $(APP_JARS) $(STATIC_ARCHIVE)

libs: $(INSTALL_TARGETS)

static: $(STATIC_ARCHIVE)

%.install:
	cd $* && lein install

test: $(addsuffix .test, $(LIBS) $(APPS))

%.test:
	cd $* && lein midje

clean:
	rm -rf $(BUILD_DIR) $(addsuffix /target, $(APPS))

$(APP_JARS): | $(BUILD_DIR)
	cd $(notdir $(@:.jar=)) && lein uberjar && cp target/uberjar/*-standalone.jar ../$@

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

docker.build:
	@for APP in $(APPS); do docker build --no-cache --build-arg JAR_FILE=$(BUILD_DIR)/$$APP.jar -t $$APP:v2 .; done

docker.build.static:
	@docker build --no-cache --build-arg COPY_SRC=front-end/public -t static:v2 -f Dockerfile_static .

docker.push:
	@for APP in $(APPS); do docker tag $$APP:v2 arunsingh1801/$$APP:v2 && docker push arunsingh1801/$$APP:v2; done

docker.push.static:
	docker tag static:v2 arunsingh1801/static:v2 && docker push arunsingh1801/static:v2

docker.up:
	@docker-compose up

infra.dev:
	cd dev && terraform init && terraform plan && terraform apply --auto-approve

destroy.dev:
	cd dev && terraform destroy

infra.test:
	cd test && terraform init && terraform plan

config.dev:
	#sleep 30
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i dev/dev-inventory config-mgmt/ansible/playbook.yml || true