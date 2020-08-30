pipeline {
    agent any
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "Maven_local"
    }
    
    options{
        // Append timestamp to the console output.
        timestamps()
        
        timeout(time: 1, unit: 'HOURS')
        
        //Donot automatically checkout the SCM at every stage. We stash what we need to save time. 
        
        skipDefaultCheckout()
        
        //Discard old builds after 10 days or 30 builds
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
        
        disableConcurrentBuilds()
    }

    stages {
        stage('Build & Test') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/aditya-kumar666/Hello-World-JAVA-master.git'
		
                // To run Maven on a Windows agent, use
                bat "mvn -f pom.xml clean install"
            }
		
            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.war'
                }
            }            
        }
        //stage('Sonar Analysis'){
        //    steps{
        //        withSonarQubeEnv('Sonar_Test'){
        //            bat "mvn sonar:sonar"
        //        }
        //    }
        //}
        stage('Artifactory'){
            steps{
                rtMavenDeployer(
                   id: 'deployers',
                   serverId: '123456789@artifactory',
                   releaseRepo: 'CI-Automation-JAVA',
                   snapshotRepo: 'CI-Automation-JAVA'
                )   
                rtMavenRun(
                    pom: 'pom.xml',
                    goals: 'clean package',
                    deployerId: 'deployers'
                )
                rtPublishBuildInfo(
                    serverId: '123456789@artifactory'
                )
            }
        }
        stage('Docker Image'){
            steps{
                bat "docker build -t dtr.nagarro.com:443/adityakumar666/java_app:$Build_NUMBER --no-cache -f Dockerfile ."
            }
        }
        stage('Push to dockerhub'){
            steps{
                bat "docker push dtr.nagarro.com:443/adityakumar666/java_app:$BUILD_NUMBER"
            }
        }
        stage('Stop running container'){
            steps{
                script{
                    conatiner = false
                    container = bat(script: "@docker ps -aqf name=java_app_instances", returnStdout: true).trim();
                    if ("$container"){
                        bat "docker stop $container"
                        bat "docker rm -f $container"
                    }
                }
            }
        }
        stage('Docker Deployment'){
            steps {
                bat "docker run --name java_app_instances -d -p 6000:8080 dtr.nagarro.com:443/adityakumar666/java_app:$BUILD_NUMBER"
            }
        }
    }
}
