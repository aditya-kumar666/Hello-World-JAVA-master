FROM tomcat:8.0
MAINTAINER Aditya Singh
RUN rm -rf /usr/local/tomcat/webapps/*
ADD http://host.docker.internal:8081/artifactory/CI-Automation-JAVA/com/nagarro/devops-tools/devops/demosampleapplication/1.0.0-SNAPSHOT/demosampleapplication-1.0.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]