FROM java:8-jdk-alpine
MAINTAINER DevOps Team
ADD http://host.docker.internal:8081/artifactory/Jenkins-release/org/springframework/boot/spring-boot-sample-atmosphere/1.4.0.RELEASE/spring-boot-sample-atmosphere-1.4.0.RELEASE.jar /usr/app/
WORKDIR /usr/app
EXPOSE 8086
ENTRYPOINT ["java", "-jar", "spring-boot-sample-atmosphere-1.4.0.RELEASE.jar"]
