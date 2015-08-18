#!/bin/bash

HADOOP_VERSION=${1}
REPLICA_NUM=${2}
IPS=${3}
HADOOP_INSTALL=${4}
NODES=( ${IPS} )

HADOOP_TMP_DIR="/tmp/hadoopTmpDir"

if [ -d "${HADOOP_INSTALL}" ]; then
	rm -r ${HADOOP_INSTALL}
fi

if [ -d "${HADOOP_TMP_DIR}" ]; then
        rm -r ${HADOOP_TMP_DIR}
fi
#install package
#apt-get update --fix-missing      
#apt-get -y --force-yes install g++ autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev
#apt-get -y --force-yes install maven 

#install hadoop src
#cd /tmp && tar -zxvf /tmp/hadoop-2.7.0-src.tar.gz
#cd /tmp/hadoop-2.7.0-src && mvn package -Pdist,native -DskipTests -Dtar 
#cp -r /tmp/hadoop-2.7.0-src/hadoop-dist/target/hadoop-2.7.0 /usr/lib/hadoop

#install hadoop 
cd /tmp && tar -zxvf /tmp/hadoop-${HADOOP_VERSION}.tar.gz
mv /tmp/hadoop-${HADOOP_VERSION}/ ${HADOOP_INSTALL} 

#set ENV
sed -i '/HADOOP_INSTALL/d' /etc/profile

sed -i 's/\${JAVA_HOME}/\/usr\/lib\/jvm/g' ${HADOOP_INSTALL}/etc/hadoop/hadoop-env.sh
sed -i '$a #HADOOP VARIABLES START' /etc/profile
sed -i '$a export HADOOP_INSTALL=/usr/lib/hadoop' /etc/profile
sed -i '$a export PATH=$PATH:$HADOOP_INSTALL/bin' /etc/profile
sed -i '$a export PATH=$PATH:$HADOOP_INSTALL/sbin' /etc/profile
sed -i '$a export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' /etc/profile
sed -i '$a export HADOOP_COMMON_HOME=$HADOOP_INSTALL' /etc/profile
sed -i '$a export HADOOP_HDFS_HOME=$HADOOP_INSTALL' /etc/profile
sed -i '$a export YARN_HOME=$HADOOP_INSTALL' /etc/profile
sed -i '$a export JAVA_LIBRARY_PATH=$HADOOP_INSTALL/lib/native' /etc/profile
sed -i '$a export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"' /etc/profile
sed -i '$a #HADOOP VARIABLES END' /etc/profile
source /etc/profile

#config hadoop core-site.xml
cp /tmp/core-site.xml ${HADOOP_INSTALL}/etc/hadoop/
sed -i 's/hadoopTmpDir/\/tmp\/hadoopTmpDir/g' ${HADOOP_INSTALL}/etc/hadoop/core-site.xml

#config hadoop hdfs-site.xml
cp /tmp/hdfs-site.xml ${HADOOP_INSTALL}/etc/hadoop/
sed -i "s/replicaNum/${REPLICA_NUM}/g" ${HADOOP_INSTALL}/etc/hadoop/hdfs-site.xml

#config hadoop mapred-site.xml
cp /tmp/mapred-site.xml ${HADOOP_INSTALL}/etc/hadoop/

##config hadoop yarn-site.xml
cp /tmp/yarn-site.xml ${HADOOP_INSTALL}/etc/hadoop/

#config hadoop slaves
if [ "${MY_IP}" == "" ];then
    MY_IP=$(python -c "import socket;socket=socket.socket();socket.connect(('8.8.8.8',53));print socket.getsockname()[0];")
fi

echo "NameNode" > ${HADOOP_INSTALL}/etc/hadoop/slaves
for i in ${!NODES[@]}; do
        if [ "${MY_IP}" != "${NODES[$i]}" ];then
            echo "DataNode-"$i"" >> ${HADOOP_INSTALL}/etc/hadoop/slaves
        fi
done

