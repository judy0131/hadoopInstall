#!/bin/bash
# Get MY_IP
if [ "${MY_IP}" == "" ];then
    MY_IP=$(python -c "import socket;socket=socket.socket();socket.connect(('8.8.8.8',53));print socket.getsockname()[0];")
fi

#1:	install root dir
#2:	hadoop nodes ips 
function set_hosts(){

	echo "###############Set Hosts Start!###############"

	ROOT_DIR=${1}
	IPS=${2}

	NODES=(${IPS})
	
	cp ${ROOT_DIR}/files/set_hosts.sh /tmp/set_hosts.sh 
	sed -i "s/ips/${IPS}/g" /tmp/set_hosts.sh

        for node in ${NODES[@]}; do
    		if [ "${MY_IP}" != "$node" ];then
    		    echo $node set hosts start
    		    scp /tmp/set_hosts.sh ${node}:/tmp/
    		    ssh root@${node} /bin/bash /tmp/set_hosts.sh
    		    echo $node set hosts end
		else
		    /bin/bash /tmp/set_hosts.sh
    		fi
	done 
	echo "###############Set Hosts End!###############"
}

#1:     hadoop nodes ips
#2:	password
function set_nopass(){
	echo "###############Set No Password Start!###############"

	IPS=${1}
	ROOT_PASS=${2}
        NODES=(${IPS})
	RSA_PATH="/root/.ssh/id_rsa"
	RSA_PUB_PATH="/root/.ssh/id_rsa.pub"
	AUTH_KEY_PATH="/root/.ssh/authorized_keys"

	#apt-get update --fix-missing
	apt-get install sshpass -y

	#remove pub key file
	if [ -f "${RSA_PATH}" ]; then
        	rm ${RSA_PATH} 
	fi	
	if [ -f "${RSA_PUB_PATH}" ]; then
                rm ${RSA_PUB_PATH}
        fi
	if [ -f "${AUTH_KEY_PATH}" ]; then
                rm ${AUTH_KEY_PATH}
        fi

	#generate pub key file
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

	for node in ${NODES[@]}; do
	    if [ "${MY_IP}" != "$node" ];then
	        echo $node copy pub key start
	        sshpass -p ${ROOT_PASS} scp -o StrictHostKeyChecking=no -r ~/.ssh/authorized_keys ${node}:/root/.ssh
	        echo $node copy pub key end
	    fi
	done
	sed -i '$a StrictHostKeyChecking no' /etc/ssh/ssh_config

	echo "###############Set No Password End!###############"
}

#1:     install root dir
#2:     hadoop nodes ips
function deploy_jdk(){
	echo "###############Deploy JDK Start!###############"

	ROOT_DIR=${1}
 	IPS=${2}
	NODES=(${IPS})

	cp ${ROOT_DIR}/package/jdk-7u80-linux-x64.tar.gz /tmp/
	cp ${ROOT_DIR}/files/install_jdk.sh /tmp/install_jdk.sh
        
	for node in ${NODES[@]}; do
	    if [ "${MY_IP}" != "$node" ];then
	        echo $node install jdk start
	        scp -r /tmp/jdk-7u80-linux-x64.tar.gz ${node}:/tmp/
	        scp /tmp/install_jdk.sh ${node}:/tmp/
	        ssh root@${node} /bin/bash /tmp/install_jdk.sh
	        ssh root@${node} /bin/bash source /etc/profile
	        echo $node install jdk  end
	    else
		/bin/bash /tmp/install_jdk.sh
		/bin/bash source /etc/profile
	    fi
		
	done 

	rm /tmp/jdk-7u80-linux-x64.tar.gz
	rm /tmp/install_jdk.sh
	
	echo "###############Deploy JDK End!###############"
}

#1:     install root dir
function install_protobuf(){
	echo "###############Install Protobuf Start!###############"

	ROOT_DIR=${1}
	#apt-get update --fix-missing
	apt-get install build-essential -y
        cp ${ROOT_DIR}/package/protobuf-2.5.0.tar.gz /tmp/
        cd /tmp && tar -zxvf /tmp/protobuf-2.5.0.tar.gz
	cd /tmp/protobuf-2.5.0 && ./configure && make && make install
	sed -i '/LD_LIBRARY_PATH/d' /etc/profile
        sed -i '$a export LD_LIBRARY_PATH=/usr/local/lib/' /etc/profile
	source /etc/profile
	rm /tmp/jdk-7u80-linux-x64.tar.gz
	rm -rf /tmp/protobuf-2.5.0

	echo "###############Install Protobuf End!###############"
}

#1:     install root dir
#2:     hadoop version, example: 2.7.0 
#3:     hdfs replicaNum
#4:     hadoop nodes ips
#5:	hadoop install path
function install_hadoop(){
	echo "###############Install Hadoop Start!###############"

        ROOT_DIR=${1}
	HADOOP_VERSION=${2}
	REPLICA_NUM=${3}
	IPS=${4}
        NODES=(${IPS})
	HADOOP_INSTALL=${5}
	echo ${HADOOP_INSTALL}
	#stop hadoop
	if [ -d "${HADOOP_INSTALL}" ]; then
        	cd ${HADOOP_INSTALL} && ./sbin/stop-dfs.sh	
		cd ${HADOOP_INSTALL} && ./sbin/stop-yarn.sh
		cd ${HADOOP_INSTALL} && ./sbin/mr-jobhistory-daemon.sh stop historyservercd	
	fi

	#copy files
	cp ${ROOT_DIR}/package/hadoop-${HADOOP_VERSION}.tar.gz /tmp/
        cp ${ROOT_DIR}/files/core-site.xml /tmp/
	cp ${ROOT_DIR}/files/hdfs-site.xml /tmp/
	cp ${ROOT_DIR}/files/mapred-site.xml /tmp/
        cp ${ROOT_DIR}/files/yarn-site.xml /tmp/
	cp ${ROOT_DIR}/files/clear_file.sh /tmp
	cp ${ROOT_DIR}/files/install_hadoop.sh /tmp/install_hadoop.sh
        
	#install namenode
	/bin/bash /tmp/install_hadoop.sh ${HADOOP_VERSION} ${REPLICA_NUM} "${NODES[*]}" ${HADOOP_INSTALL} 

        #install datanoade
	for node in ${NODES[@]}; do
            if [ "${MY_IP}" != "$node" ];then
                echo $node install hadoop start
		scp /tmp/clear_file.sh ${node}:/tmp/
                ssh root@${node} /bin/bash /tmp/clear_file.sh ${HADOOP_INSTALL}
		scp -r ${HADOOP_INSTALL} root@${node}:${HADOOP_INSTALL}
                echo $node install hadoop  end
            fi
        done

	#format and start hadoop 	
	cd ${HADOOP_INSTALL} && ./bin/hdfs namenode -format
	cd ${HADOOP_INSTALL} && ./sbin/start-dfs.sh
	cd ${HADOOP_INSTALL} && ./sbin/start-yarn.sh  
	cd ${HADOOP_INSTALL} && ./sbin/mr-jobhistory-daemon.sh start historyserver

	#remove files
	#rm -r /tmp/hadoop-${HADOOP_VERSION}.tar.gz
	rm -r /tmp/core-site.xml
	rm -r /tmp/hdfs-site.xml
	rm -r /tmp/mapred-site.xml
	rm -r /tmp/yarn-site.xml
	rm -r /tmp/install_hadoop.sh

	echo "###############Install Hadoop End!###############"
}
