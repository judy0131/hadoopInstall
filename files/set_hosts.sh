#!/bin/bash
NODES=(ips)

#get MyIp
if [ "${MY_IP}" == "" ];then
    MY_IP=$(python -c "import socket;socket=socket.socket();socket.connect(('8.8.8.8',53));print socket.getsockname()[0];")
fi

sed -i '/NameNode/d' /etc/hosts
sed -i '/DataNode/d' /etc/hosts

for i in ${!NODES[@]}; do

    if [ "${i}" == "0" ];then
	echo "${NODES[$i]}  NameNode" >> /etc/hosts 
        if [ "${MY_IP}" == "${NODES[$i]}" ];then
		echo "NameNode" > /etc/hostname
		hostname -F /etc/hostname
	fi
    else
    	#node_index=`expr $i + 1`
    	echo "${NODES[$i]}  DataNode-"$i"" >> /etc/hosts
	if [ "${MY_IP}" == "${NODES[$i]}" ];then
                echo "DataNode-"$i"" > /etc/hostname
		hostname -F /etc/hostname
        fi
    fi
done
