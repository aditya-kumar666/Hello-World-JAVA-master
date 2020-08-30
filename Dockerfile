FROM tomcat:8.0
RUN rm -rf /usr/local/tomcat/webapps/*
ADD http://host.docker.internal:8081/artifactory/CI-Automation-JAVA/com/nagarro/devops-tools/devops/demosampleapplication/1.0.0-SNAPSHOT/ /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]