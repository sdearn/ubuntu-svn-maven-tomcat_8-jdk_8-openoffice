FROM ubuntu:14.04

MAINTAINER sdearn<540797670@qq.com>

RUN sudo rm -f /etc/localtime \
    && sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN sudo apt-get update \
    && sudo apt-get install -y wget \
    && sudo apt-get install -y zip \
    && sudo apt-get install -y vim \
    && sudo apt-get install -y xvfb


RUN sudo apt-get install -y subversion

ADD file/ work/

#ADD file/docker-entrypoint.sh work/docker-entrypoint.sh
#ADD file/settings.xml work/settings.xml
#ADD file/java.security work/java.security

WORKDIR /work

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm

RUN ["chmod", "+x", "/work/jdk-8u131-linux-x64.rpm"]

RUN rpm -ivh jdk-8u131-linux-x64.rpm

RUN echo "export JAVA_HOME=/usr/java/jdk1.8.0_131">>/etc/profile
RUN echo "export JRE_HOME=$JAVA_HOME/jre">>/etc/profile
RUN echo "export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH">>/etc/profile
RUN echo "export JAVA_PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin">>/etc/profile
RUN echo "export PATH=$PATH:${JAVA_PATH}">>/etc/profile

RUN mkdir -p /root/.m2/ && mv settings.xml /root/.m2/
    
#RUN mv java.security /usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/lib/security/

RUN ["chmod", "+x", "/work/docker-entrypoint.sh"]

RUN unzip apache-tomcat*.zip && rm -f apache-tomcat*.zip && mv apache-tomcat* tomcat

RUN unzip apache-maven*.zip && rm -f apache-maven*.zip && mv apache-maven* maven

RUN echo "export M2_HOME=/work/maven">>/etc/profile
RUN echo "export PATH=$M2_HOME/bin:$PATH">>/etc/profile
    
RUN cd /work/Apache_OpenOffice_zh-CN/DEBS && sudo dpkg -i *.deb

RUN cd /work/Apache_OpenOffice_zh-CN/DEBS/desktop-integration && sudo dpkg -i openoffice4.1-debian-menus_4.1.5-9789_all.deb

RUN cd /work && rm -rf Apache_OpenOffice_zh-CN

RUN mv fonts/* /opt/openoffice4/share/fonts/truetype/ && rm -rf fonts

WORKDIR /work

EXPOSE 8080

ENTRYPOINT ["/work/docker-entrypoint.sh"]
