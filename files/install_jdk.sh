#!/bin/bash

ps -ef | grep java | grep -v grep | grep -v install_jdk.sh | awk '{print $2}'| xargs kill
apt-get -y --force-yes install build-essential dpkg-dev sshpass libssl-dev flex bison
rm -rf /usr/lib/jvm || true

if [ ! -x /usr/lib/jvm/bin/java ];then
    sed -i '/JAVA_HOME/d' /etc/profile
    sed -i '/JRE_HOME/d' /etc/profile    

    cd /tmp && tar -zxvf /tmp/jdk-7u80-linux-x64.tar.gz
    mv /tmp/jdk1.7.0_80 /usr/lib/jvm
    sed -i '$a export JAVA_HOME=/usr/lib/jvm' /etc/profile
    sed -i '$a export JRE_HOME=/usr/lib/jvm/jre' /etc/profile
    sed -i '$a export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH' /etc/profile
    sed -i '$a export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' /etc/profile
    source /etc/profile
fi
