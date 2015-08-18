#!/bin/bash
NODES=(10.0.96.192 10.0.96.193 10.0.96.194)
PASS=root
HADOOP_VERSION=2.7.1
REPLICA_NUM=1
HADOOP_INSTALL="/usr/lib/hadoop"

ROOT_DIR=$(cd $(dirname "$0")/ && pwd)
source ${ROOT_DIR}/common.sh

apt-get update --fix-missing

if [ $# == 0 ]; then 
    set_nopass "${NODES[*]}" $PASS
    set_hosts ${ROOT_DIR} "${NODES[*]}" 
    install_protobuf ${ROOT_DIR}
    deploy_jdk ${ROOT_DIR} "${NODES[*]}"
    install_hadoop ${ROOT_DIR} ${HADOOP_VERSION} ${REPLICA_NUM}  "${NODES[*]}" ${HADOOP_INSTALL}

elif [ $# == 1 ]; then
    if [ $1 == "nopass" ]; then
	set_nopass "${NODES[*]}" $PASS
    elif [ $1 == "common" ]; then
        set_hosts ${ROOT_DIR} "${NODES[*]}"
    	install_protobuf ${ROOT_DIR}
    	deploy_jdk ${ROOT_DIR} "${NODES[*]}"

    elif [ $1 == "hadoop" ]; then
	install_hadoop ${ROOT_DIR} ${HADOOP_VERSION} ${REPLICA_NUM}  "${NODES[*]}" ${HADOOP_INSTALL}

    else
        echo "USAGE: $0" 
        echo "USAGE: $0 common"
        echo "USAGE: $0 hadoop"
    fi

else
    echo "USAGE: $0" 
    echo "USAGE: $0 common"
    echo "USAGE: $0 hadoop"
	
fi
