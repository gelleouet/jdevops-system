# smarthome-system

Outils d'installation et de configuration d'une instance jdevops

## Firewall

## AWS CLI

Installation python3 et pip

    apt-get install python3
    apt-get install python3-pip

Installation aws cli  
https://docs.aws.amazon.com/fr_fr/cli/latest/userguide/install-linux.html

    pip3 install awscli --upgrade --user
    
Ajout des infos de connexion dans le fichier /root/.aws/credentials  
https://docs.aws.amazon.com/fr_fr/cli/latest/userguide/cli-configure-files.html

    [default]
    aws_access_key_id=
    aws_secret_access_key=
    
fichier de configuration /root/.aws/config   
 
    [default]
    region=eu-west-3