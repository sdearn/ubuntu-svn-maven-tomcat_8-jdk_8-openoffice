#!/bin/bash

set -x

app_name="${APP_NAME:-default}"
build_file="${BUILD_FILE:-ROOT.war}"
build_cmd="${BUILD_CMD:-clean package -Dmaven.test.skip=true}"
environment="${ENVIRONMENT:-pom.xml.test}"

mkdir project

echo "yes" | svn co --username=${SVN_USER} --password=${SVN_PWD}  ${SVN_URL} project/${app_name}

cd  project/${app_name}

yes|cp -r ${environment} pom.xml

../../maven/bin/mvn ${build_cmd}

cd ../../

mv tomcat/webapps/ROOT tomcat/webapps/ROOT.bak

cp project/${app_name}/target/${build_file} tomcat/webapps

sed -i "2i JAVA_OPTS=\"$JAVA_OPTS -Dfile.encoding=UTF8  -Duser.timezone=GMT+08\"" /work/tomcat/bin/catalina.sh

chmod +x /work/tomcat/bin/catalina.sh

xvfb-run -a /opt/openoffice4/program/soffice -headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard &

/work/tomcat/bin/catalina.sh run
