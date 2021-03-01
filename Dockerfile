FROM openjdk:17-jdk-alpine3.13
ARG JAR_FILE

WORKDIR /

COPY $JAR_FILE .

COPY set_env.sh /set_env.sh

RUN chmod +x /set_env.sh

ENTRYPOINT ["/set_env.sh"]
CMD ["/bin/sh", "-c", "java -jar *.jar"]