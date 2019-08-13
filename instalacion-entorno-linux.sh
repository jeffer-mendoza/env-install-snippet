#!/bin/bash

# Script's inicialization of the tools need to webapp development "Auditoría de
# Proyectos Gore". This script will download all packages need and it will 
# install and configure.

# This Script will install the following tools: 

# 1. Spring Tool Suite v3.9.5
# 2. Apache Maven v3.5.4
# 3. Mysql v5.9
# 4. Mysql Workbench v6.3
# 5. Apache Tomcat v.8.5.30

# @Author Jefferson Mendoza <mendosajefferson@gmail.com>

# Install Directory
INSTALL_FOLDER="$HOME/auditoria-proyectos-gore-tools/"

# Maven Directory
MAVEN_FOLDER="$INSTALL_FOLDER/apache-maven-3.5.4"

# STS Directory
STS_FOLDER="$INSTALL_FOLDER/sts-bundle"

# Java JDK Directory
JAVA_JDK_FOLDER="$INSTALL_FOLDER/jdk1.8.0_181"

# Apache Tomcat Directory
TOMCAT_FOLDER="$INSTALL_FOLDER/apache-tomcat-8.5.32"

# Workspace Directory
WORKSPACE_FOLDER="$HOME/devel"

# Project Directory
PROJECT_FOLDER="$WORKSPACE_FOLDER/datactil-auditoria-de-proyectos-gore"

# Enviroment Variable File
FILE_SETUP="~/.gorerc"

# Database Name
DATABASE_NAME="gore_app"

# Database User's Password
DATABASE_USER_PASSWORD="gore_app_password"

# Database User's Name
DATABASE_USER_NAME="gore_user"

conclusion="This script made: \n"

# Init install folder
if [ ! -d "$INSTALL_FOLDER" ]; then
    echo '[+] Creating folder' "$INSTALL_FOLDER"
    mkdir "$INSTALL_FOLDER"
fi

# the system must have installed the Java JDK 8u181 
if [ ! -d "$JAVA_JDK_FOLDER" ]; then
    echo 'This script need the Java JDK 8u181'
    echo 'For downloading: http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html'
    echo '1. Download Java Jdk 8u181'
    echo '2. Execute command: tar -xzvf jdk-8u181-linux-x64.tar.gz --directory ' $INSTALL_FOLDER
    xdg-open http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html & 
    exit 0
fi

cd /tmp

# 1. Spring Tool Suite v3.9.5
# if STS folder doesn't exist then STS IDE will be downloaded and decompressed.
if [ ! -d "$STS_FOLDER" ]; then
    echo '[+] Downloading STS v3.9.5'
    wget https://download.springsource.com/release/STS/3.9.5.RELEASE/dist/e4.8/spring-tool-suite-3.9.5.RELEASE-e4.8.0-linux-gtk-x86_64.tar.gz

    tar -xzvf spring-tool-suite-3.9.5.RELEASE-e4.8.0-linux-gtk-x86_64.tar.gz --directory $INSTALL_FOLDER

    # creating Desktop Entry
    cat << EOF > $HOME/.local/share/applications/sts.desktop
[Desktop Entry]
Version=3.9.5
Type=Application
Name=STS
Icon=$STS_FOLDER/sts-3.9.5.RELEASE/icon.xpm
Exec=$STS_FOLDER/sts-3.9.5.RELEASE/STS
Comment=Spring Tool Suite
Categories=Development;IDE;
Terminal=false
EOF
fi



# 2. MAVEN v3.5.4

# if Apache Maven folder doesn't exist then Maven will be downloaded and
# decompressed.
if [ ! -d "$MAVEN_FOLDER" ]; then
    echo '[+] Downloading Apache Maven v3.5.4'
    wget http://apache.uniminuto.edu/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
    tar -xzvf apache-maven-3.5.4-bin.tar.gz --directory $INSTALL_FOLDER
fi

# if Enviroment Variable File doesn't exist in bashrc file then it will be added
if  ! grep -q "source ~/.gorerc" $HOME/.bashrc; then
    echo '[+] Adding .gorerc in .bashrc'
    echo "source ~/.gorerc" >> $HOME/.bashrc
fi

# if Enviroment Variable File doesn't exist the it will be created with 
# Maven and JAVA_HOME variable defined.
if [ ! -f "$FILE_SETUP" ]; then
    cat << EOF > $HOME/.gorerc
export PATH=$MAVEN_FOLDER/bin:$PATH
export JAVA_HOME=$JAVA_JDK_FOLDER
EOF
fi


# 3. MYSQL SERVER v5.7
# if Mysql-server packaged isn
if dpkg-query -l mysql-server | grep -c "no packages" -eq 0; then 
    echo '[+] Downloading and installing mysql-server package v5.7' 
    # mysql repository is updated
    curl -OL https://dev.mysql.com/get/mysql-apt-config_0.8.10-1_all.deb
    sudo dpkg -i mysql-apt-config*
    sudo apt-get update
    rm mysql-apt-config*
    # mysql-server is installed
    sudo apt-get install mysql-server
    echo "Please enter root user MySQL password!"
    read rootpasswd
    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${DATABASE_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${DATABASE_USER_NAME}@localhost IDENTIFIED BY '${DATABASE_USER_PASSWORD}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* TO '${DATABASE_USER_NAME}'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"

    # 4. MYSQL WORKBENCH v6.3
    echo '[+] Downloading and installing mysql-workbench v6.30'
    sudo apt-get install mysql-workbench
else
    echo '[-] Mysql-server package is already installed in the system'
fi

# 5. APACHE TOMCAT v8.5.30

# if Apache Tomcat folder doesn't exist then it will be downloaded and
# decompressed.
if [ ! -d "$TOMCAT_FOLDER" ]; then
    echo '[+] Downloading Apache Tomcat v8.5.30'
    wget http://apache.uniminuto.edu/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
    tar -xzvf apache-tomcat-8.5.32.tar.gz --directory $INSTALL_FOLDER 
fi


# 6. Clone Project
if [ ! -d "$WORKSPACE_FOLDER" ]; then
    mkdir "$WORKSPACE_FOLDER"
fi

if [ ! -d "$PROJECT_FOLDER" ]; then
    echo '[+] Cloning Planio Project'
    cd "$WORKSPACE_FOLDER"
    git clone git@digitgroup.plan.io:digitgroup/datactil-auditoria-de-proyectos-gore.git -b develop
fi

