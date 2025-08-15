pipeline {
    agent any

    environment {
        TARGET_FILE = 'targets.txt'
        REPORT_FILE = 'report-nuclei.txt'
    }

    stages {
        stage('Clone repo') {
            steps {
                git branch: 'main', url: 'https://github.com/ineszenk/pipeline-jenkins'
            }
        }

        stage('Install npm package and launch Node.js') {
            steps {
                sh '''
                npm install
                nohup node server.js &
                sleep 5
                '''
            }
        }

        stage('Launch Nuclei scan') {
            steps {
                sh '''
                # Prepare target file
                echo http://host.docker.internal:3000 > $TARGET_FILE

                # Launch scan
                nuclei -l $TARGET_FILE \
                       -t /var/jenkins_home/nuclei-templates \
                       -severity high,medium,low \
                       -o $REPORT_FILE || true
                '''
            }
        }

        stage('Print Nuclei report') {
            steps {
                sh '''
                echo "-------*****-------*****-------*****-------*****"
                cat $REPORT_FILE
                echo "-------*****-------*****-------*****-------*****"
                '''
            }
        }

        stage('Check for Vulnerability Findings') {
            steps {
                script {
                    def reportContent = readFile(env.REPORT_FILE)
                    if (reportContent.contains("high") || reportContent.contains("medium") || reportContent.contains("low")) {
                        error("Vulnerabilities found by Nuclei! Build failed.")
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
