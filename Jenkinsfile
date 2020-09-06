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

    // environment{
    //     KUBECONFIG = 'C:\\Users\\adityasingh01\\.kube\\config'
    // }

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
        // stage('Push to docker:dtr'){
        //     steps{
        //         bat "docker push dtr.nagarro.com:443/i_adityasingh01_master:$BUILD_NUMBER"
        //     }
        // }
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
                kubeconfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01EZ3hPVEUxTXpNeE1sb1hEVE13TURneE56RTFNek14TWxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTE10CkZLZUxKY1VNZnFyMG9OUWZBSU9peU1lZHRBZ3VTcTdjWHoxMjFORjJFREt3Szg4cDg0bDk1cFhuNlNlMHk1aTQKcHNNenMyTHhUSVZGMGxtQStkWmpZbDhEeHJmbWhwL1QyL0p4ZnhTclZrUmdlMlA2akpjc2lzT0ZnRkhNMHRQbQp4UEk4NEw3NUttK2lZYUdJME1sYUk4dGwrVDMxSVd6eE9wRFhEQnRBOU9YZ1haLytzSFNudGxLbEI0ZEsyUi9YCmk5ODcwMmYxRmdnUzZYaUp3cDl3dHloRHhyQXpYUDBudEJFa3NwenVEd005Z0pmZUhiTWZkdnZBSjZvdjNIRVgKWXBnc1lmYmExR2FGbDhMaytSRXB0UzR1ZUNheDdxQ2lBLzZRTzBBdFZLRzRzR2lUR211bElkUE8wQ2g0Y1BFMApQbTI3eWVza1lBcEFWRVhhbHIwQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFBd1FHazl3bHNURyt5SFFIU2hBNEMxQ0NZNlQKZjJJZFdLbjNpWEt6ZWdTMUJJbW5zMndXWlIxZ3FpQjJnTmoyWlZ5MndESFZiekhjNlpyTlo0WmhvNVl3b25PVwpLUjA2L0NpQmdJd3NLNm9pL3BwUDFRWUxDaXk4QXpvR21oY1pDenFHVmszdVR5V3ZGMWo4YTdMRHlmaGt1bE9CCkJ0Vld2YWU0UnlrbGZ3YTdUNkRPN1lCRm9ZL0lzeXY3M3hjL2dNczJNaUZVLzhuUlZYOXVTa2liK1VmTUV4SEwKcHN1RmdUMmQ4T25sUWNkcWlrVEJLeFZzalh5Y0JhaFE5TDByRWh5WERHTEFMVlRNN0lRSkJhYnRvYyt2eGJ2ZgoyUkpSY0VRS2VFWVpGMEJadUpVYTgwNGowNzl4VEVpMXkxTEs0VjRTL2M2NHUwazN0bzRyUUpKdTZOOD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo', serverUrl: 'https://kubernetes.docker.internal:6443') {
                    bat "kubectl version"
                    bat "helm version"
                    bat "helm upgrade --install --force nagp-assignment aditya-nagp-assignment --set image=dtr.nagarro.com:443/i_adityasingh01_master:$BUILD_NUMBER"
                }
            }
        }
    }
}
