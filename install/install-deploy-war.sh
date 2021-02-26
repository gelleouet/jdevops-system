# Installation du script de deploy de l'application
# Les scripts sont copiés dans le dossier /usr/local/bin et sont accessibles
# directement car présent dans PATH
#
# Demande les chemins aux repertoires necessaires (grails, java, template,
# instance tomcat) et construit les scripts relatifs à cette config
#
# Installe aussi le service systemd pour cette application
# le service n'est pas activé par le script
# il faut lancer manuellement systemctl enable ....
#
# @author Gregory Elleouet <gregory.elleouet@gmail.com>
#

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage : install-deploy project-name"
  exit 1
fi

CONFIG_FILE="/root/.${PROJECT_NAME}.build"
PATH_SCRIPT="/usr/local/bin"


# charge la dernière conf build

if [ -f "$CONFIG_FILE" ]; then
	DEFAULT_JAVA_HOME=`grep "JAVA_HOME" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_CATALINA_BASE=`grep "CATALINA_BASE" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_DEPLOY_PATH=`grep "DEPLOY_PATH" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_INTEGRATION_URL=`grep "INTEGRATION_URL" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_DEPLOY_CONTEXT=`grep "DEPLOY_CONTEXT" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_HTTP_PORT=`grep "HTTP_PORT" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_JDBC_HOST=`grep "JDBC_HOST" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_JDBC_PORT=`grep "JDBC_PORT" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_JDBC_DATABASE=`grep "JDBC_DATABASE" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_JDBC_USER=`grep "JDBC_USER" $CONFIG_FILE | awk -F "=" '{print $2}'`
	DEFAULT_JDBC_PASSWORD=`grep "JDBC_PASSWORD" $CONFIG_FILE | awk -F "=" '{print $2}'`
fi

# Quelques valeurs par défaut

if [ -z "$DEFAULT_HTTP_PORT" ]; then
	DEFAULT_HTTP_PORT=8080
fi
if [ -z "$DEFAULT_JDBC_HOST" ]; then
	DEFAULT_JDBC_HOST="localhost"
fi
if [ -z "$DEFAULT_JDBC_PORT" ]; then
	DEFAULT_JDBC_PORT=5432
fi


# Config du user

echo "-------------------"
echo "Java environnement"
echo "------------------"
read -p "Java home [default=$DEFAULT_JAVA_HOME]: " JAVA_HOME
read -p "Catalina base [default=$DEFAULT_CATALINA_BASE]: " CATALINA_BASE

echo "-------------------"
echo "Deploy environnement"
echo "--------------------"
read -p "Integration URL [default=$DEFAULT_INTEGRATION_URL]: " INTEGRATION_URL
read -p "Deploy path [default=$DEFAULT_DEPLOY_PATH]: " DEPLOY_PATH
read -p "Deploy context [default=$DEFAULT_DEPLOY_CONTEXT]: " DEPLOY_CONTEXT
read -p "HTTP port [default=$DEFAULT_HTTP_PORT]: " HTTP_PORT
read -p "JDBC host [default=$DEFAULT_JDBC_HOST]: " JDBC_HOST
read -p "JDBC port [default=$DEFAULT_JDBC_PORT]: " JDBC_PORT
read -p "JDBC database [default=$DEFAULT_JDBC_DATABASE]: " JDBC_DATABASE
read -p "JDBC user  [default=$DEFAULT_JDBC_USER]: " JDBC_USER
read -p "JDBC password  [default=$DEFAULT_JDBC_PASSWORD]: " JDBC_PASSWORD

if [ -z "$JAVA_HOME" ] && [ -z "$DEFAULT_JAVA_HOME" ]; then
  echo "Java home is required !"
  exit 1
elif [ -z "$JAVA_HOME" ]; then
	JAVA_HOME="$DEFAULT_JAVA_HOME"
fi

if [ -z "$INTEGRATION_URL" ] && [ -z "$DEFAULT_INTEGRATION_URL" ]; then
  echo "Integration URL is required !"
  exit 1
elif [ -z "$INTEGRATION_URL" ]; then
	INTEGRATION_URL="$DEFAULT_INTEGRATION_URL"
fi

if [ -z "$CATALINA_BASE" ] && [ -z "$DEFAULT_CATALINA_BASE" ]; then
  echo "Catalina base is required !"
  exit 1
elif [ -z "$CATALINA_BASE" ]; then
	CATALINA_BASE="$DEFAULT_CATALINA_BASE"
fi

if [ -z "$DEPLOY_PATH" ] && [ -z "$DEFAULT_DEPLOY_PATH" ]; then
  echo "Deploy path is required !"
  exit 1
elif [ -z "$DEPLOY_PATH" ]; then
	DEPLOY_PATH="$DEFAULT_DEPLOY_PATH"
fi

if [ -z "$DEPLOY_CONTEXT" ] && [ -z "$DEFAULT_DEPLOY_CONTEXT" ]; then
  echo "Deploy context is required !"
  exit 1
elif [ -z "$DEPLOY_CONTEXT" ]; then
	DEPLOY_CONTEXT="$DEFAULT_DEPLOY_CONTEXT"
fi

if [ -z "$HTTP_PORT" ]; then
	HTTP_PORT="$DEFAULT_HTTP_PORT"
fi

if [ -z "$JDBC_HOST" ]; then
	JDBC_HOST="$DEFAULT_JDBC_HOST"
fi

if [ -z "$JDBC_PORT" ]; then
	JDBC_PORT="$DEFAULT_JDBC_PORT"
fi

if [ -z "$JDBC_DATABASE" ] && [ -z "$DEFAULT_JDBC_DATABASE" ]; then
  echo "JDBC database is required !"
  exit 1
elif [ -z "$JDBC_DATABASE" ]; then
	JDBC_DATABASE="$DEFAULT_JDBC_DATABASE"
fi

if [ -z "$JDBC_USER" ] && [ -z "$DEFAULT_JDBC_USER" ]; then
  echo "JDBC user is required !"
  exit 1
elif [ -z "$JDBC_USER" ]; then
	JDBC_USER="$DEFAULT_JDBC_USER"
fi

if [ -z "$JDBC_PASSWORD" ] && [ -z "$DEFAULT_JDBC_PASSWORD" ]; then
  echo "JDBC password is required !"
  exit 1
elif [ -z "$JDBC_PASSWORD" ]; then
	JDBC_PASSWORD="$DEFAULT_JDBC_PASSWORD"
fi


# Sauvegarde la config

echo "JAVA_HOME=$JAVA_HOME" > $CONFIG_FILE
echo "CATALINA_BASE=$CATALINA_BASE" >> $CONFIG_FILE
echo "INTEGRATION_URL=$INTEGRATION_URL" >> $CONFIG_FILE
echo "DEPLOY_PATH=$DEPLOY_PATH" >> $CONFIG_FILE
echo "DEPLOY_CONTEXT=$DEPLOY_CONTEXT" >> $CONFIG_FILE
echo "HTTP_PORT=$HTTP_PORT" >> $CONFIG_FILE
echo "JDBC_HOST=$JDBC_HOST" >> $CONFIG_FILE
echo "JDBC_PORT=$JDBC_PORT" >> $CONFIG_FILE
echo "JDBC_DATABASE=$JDBC_DATABASE" >> $CONFIG_FILE
echo "JDBC_USER=$JDBC_USER" >> $CONFIG_FILE
echo "JDBC_PASSWORD=$JDBC_PASSWORD" >> $CONFIG_FILE



# Construction du script deploy "[proxy-name]-deploy.sh"
# il est possible de creer plusieurs instances en specifiant un id (numero) dans le contexte d'un cluster HA
# Installe le service systemd associé à l'instance

SYSTEMD_PATH="/etc/systemd/system"

cat <<EOF > ${PATH_SCRIPT}/${PROJECT_NAME}-deploy.sh
INSTANCE_ID=\$1

if [ -z "\$INSTANCE_ID" ]; then
  read -p "Instance ID [1-9]: " INSTANCE_ID
fi

read -p "Project version [x.y.z]: " PROJECT_VERSION
INSTANCE_NAME="${PROJECT_NAME}-\${INSTANCE_ID}"
INSTANCE="$DEPLOY_PATH/\$INSTANCE_NAME"
WAR_FILE="${PROJECT_NAME}-\${PROJECT_VERSION}.war"

if [ -z "\$INSTANCE_ID" ]; then
  echo "Instance ID is required !"
  exit 1
fi

if [ -z "\$PROJECT_VERSION" ]; then
  echo "Project version is required !"
  exit 1
fi

rm -r \$INSTANCE
mkdir \$INSTANCE
mkdir \$INSTANCE/conf
mkdir \$INSTANCE/logs
mkdir \$INSTANCE/temp
cp -r $CATALINA_BASE/conf/application.yml \$INSTANCE/conf
scp -i /root/.ssh/jdevops.key -P 22000 $INTEGRATION_URL:/opt/artefacts/\$WAR_FILE \$INSTANCE/${DEPLOY_CONTEXT}.war

sed -i -e "s/8080/\${INSTANCE_ID}${HTTP_PORT}/g" \$INSTANCE/conf/application.yml

sed -i -e "s/#jdbc-host#/${JDBC_HOST}/g" \$INSTANCE/conf/application.yml
sed -i -e "s/#jdbc-port#/${JDBC_PORT}/g" \$INSTANCE/conf/application.yml
sed -i -e "s/#jdbc-database#/${JDBC_DATABASE}/g" \$INSTANCE/conf/application.yml
sed -i -e "s/#jdbc-user#/${JDBC_USER}/g" \$INSTANCE/conf/application.yml
sed -i -e "s/#jdbc-password#/${JDBC_PASSWORD}/g" \$INSTANCE/conf/application.yml

# astuce pour proteger le £ dans le fichier MAINPID
# sinon il est interpreté à l'excution du fichier deploy
# (il est protege a l'exuction du fichier install avec le \)
MAINPID=\`printf "\\x24MAINPID"\`

cat <<EOF1 > ${SYSTEMD_PATH}/\${INSTANCE_NAME}.service
[Unit]
Description=Webapp Application
After=syslog.target network.target

[Service]
Type=forking
Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_BASE=\$INSTANCE"
ExecStart=$JAVA_HOME/bin/java -server -Xmx1024M -Xms1024M -XX:MaxMetaspaceSize=768M -Duser.language=fr -Duser.region=FR -Duser.timezone=Europe/Paris -Dspring.config.additional-location=\$CATALINA_BASE/conf/application.yml -jar \$CATALINA_BASE/${DEPLOY_CONTEXT}.war
ExecStop=/bin/kill -15 \$MAINPID
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF1

# recharge la conf systemd
systemctl daemon-reload

EOF

chmod +x ${PATH_SCRIPT}/${PROJECT_NAME}-deploy.sh

