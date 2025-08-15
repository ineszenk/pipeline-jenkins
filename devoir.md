## Objectifs


**Modification du Jenkinsfile** : Modifiez le script Jenkinsfile pour que Jenkins :Ne fasse plus d'analyse statique avec Semgrep.

Ajoute une étape pour instancier l'application serveur avec Node.js.

Lance ensuite l'outil de test dynamique (DAST) **Nuclei** sur le serveur pour détecter les vulnérabilités.

**Rapport et condition de build** :Les résultats du scan de Nuclei doivent être stockés dans un fichier report-nuclei.txt.

Si des vulnérabilités de niveau **high**, **medium** ou **low** sont trouvées, le build doit échouer avec une erreur.


## 1 . Modification Dockerfile :

**Ajout de l’installation de nuclei directement dans le dockerfile**  

```dockerfile
RUN curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
    | grep "browser_download_url" \
    | grep "nuclei_.*_linux_arm64.zip" \
    | cut -d '"' -f 4 \
    | xargs curl -LO && \
    unzip nuclei_*_linux_arm64.zip && \
    mv nuclei /usr/local/bin/ && \
    rm nuclei_*_linux_arm64.zip
```

## 2 . Modification Jenkinsfile :

- Définir des variables d’environnement `target_file` et `report-nuclei`
- Installer les packages nécessaires au lancement du serveur
- Lancer le serveur Node.js (car Nuclei effectue une analyse dynamique nécessitant que le serveur tourne)
- Lancer le scan Nuclei
  - Scan de l’URL du serveur cible avec les templates des vulnérabilités et les sévérités
  - Sauvegarde du résultat dans le fichier `report-nuclei.txt`
  - Pipeline qui continue même si Nuclei détecte des vulnérabilités pour générer le rapport et l’afficher
  - Décider si le build échoue en fonction des vulnérabilités trouvées


    ```groovy
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

