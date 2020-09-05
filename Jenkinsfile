pipeline {
    agent any
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "Maven3"
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
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/aditya-kumar666/Hello-World-JAVA-master.git'
		
                // To run Maven on a Windows agent, use
                bat "mvn -f pom.xml clean install"
            }
		
            post {
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }            
        }
        stage('Unit Testing'){
            steps{
                bat 'mvn test'
            }
        }
        stage('Sonar Analysis'){
           steps{
               withSonarQubeEnv('Test_Sonar'){
                   bat "mvn sonar:sonar"
               }
           }
        }
        stage('Artifactory'){
            steps{
                rtMavenDeployer(
                   id: 'deployer',
                   serverId: '123456789@artifactory',
                   releaseRepo: 'CI-Automation-JAVA',
                   snapshotRepo: 'CI-Automation-JAVA'
                )   
                rtMavenRun(
                    pom: 'pom.xml',
                    goals: 'clean package',
                    deployerId: 'deployer'
                )
                rtPublishBuildInfo(
                    serverId: '123456789@artifactory'
                )
            }
        }
        stage('Docker Image'){
            steps{
                bat "docker build -t dtr.nagarro.com:443/i_adityasingh01_master:$Build_NUMBER --no-cache -f Dockerfile ."
            }
        }
        stage('Push to docker:dtr'){
            steps{
                //bat "docker push dtr.nagarro.com:443/i_adityasingh01_master:$BUILD_NUMBER"
            }
        }
        stage('Stop running container'){
            steps{
                script{
                    conatiner = false
                    container = bat(script: "@docker ps -aqf name=c_adityasingh01_master", returnStdout: true).trim();
                    if ("$container"){
                        bat "docker stop $container"
                        bat "docker rm -f $container"
                    }
                }
            }
        }
        stage('Docker Deployment'){
            steps {
                bat "docker run --name c_adityasingh01_master -d -p 6000:8080 dtr.nagarro.com:443/i_adityasingh01_master:$BUILD_NUMBER"
            }
        }
        stage('Helm Chart Deployment'){
            steps{
                bat "helm upgrade --install --force nagp-assignment aditya-nagp-assignment --set image=dtr.nagarro.com:443/i_adityasingh01_master:$BUILD_NUMBER"
            }
        }
    }
}
