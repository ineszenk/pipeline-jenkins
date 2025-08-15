# Utilise l'image Jenkins LTS avec JDK 17 comme base
FROM jenkins/jenkins:lts-jdk17

# Passer en mode root pour installer les paquets
USER root

# Installer Node.js, npm, Python3 avec venv et curl
RUN apt-get update && \
    apt-get install -y nodejs npm python3 python3-pip python3-venv curl tar && \
    rm -rf /var/lib/apt/lists/*

# Vérification pour que python3 soit disponible dans la commande CLI `python3`
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Installer Nuclei
RUN curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
    | grep "browser_download_url" \
    | grep "nuclei_.*_linux_arm64.zip" \
    | cut -d '"' -f 4 \
    | xargs curl -LO && \
    unzip nuclei_*_linux_arm64.zip && \
    mv nuclei /usr/local/bin/ && \
    rm nuclei_*_linux_arm64.zip

# Revenir à l'utilisateur Jenkins pour la sécurité
USER jenkins
