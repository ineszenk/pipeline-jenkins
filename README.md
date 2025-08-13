# pipeline-jenkins

Sans modifier le code source du serveur :

**Modification du Jenkinsfile** : Modifiez le script Jenkinsfile pour que Jenkins :Ne fasse plus d'analyse statique avec Semgrep.

Ajoute une étape pour instancier l'application serveur avec Node.js.

Lance ensuite l'outil de test dynamique (DAST) **Nuclei** sur le serveur pour détecter les vulnérabilités.

**Rapport et condition de build** :Les résultats du scan de Nuclei doivent être stockés dans un fichier report-nuclei.txt.

Si des vulnérabilités de niveau **high**, **medium** ou **low** sont trouvées, le build doit échouer avec une erreur.

Si aucune vulnérabilité n'est détectée, le build doit se terminer avec succès.

**Forme des rendus**

Sous forme de repository Github (en public) et envoyer un mail a contact@hash24security.com avec un texte explicatif et le lien du repo.