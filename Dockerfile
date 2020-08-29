FROM tomcat:8.0
RUN rm -rf /usr/app/*
COPY ./target/devopssampleapplication.war /usr/app/
CMD ["catalina.sh", "run"]