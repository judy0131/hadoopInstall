# hadoopInstall
auto deploy hadoop in ubuntu12.04 or ubuntu14.04

first, edit deploy.sh

	1. modify NODES, the first node is namenode --> NODES=(10.0.98.59 10.0.98.63)

	2. modify PASS (password of each node)

	3: modify HADOOP_VERSION
	   support 2.6.0 2.7.0 2.7.1,
	   you can download others version tar.gz, 
	   put it into "package" folder,and modify HADOOP_VERSION

	4: modify REPLICA_NUM(hdfs replication number)

second, execute deploy.sh

	1. "./deploy.sh" deploy hadoop cluster
	2. "./deploy.sh common" just deploy hadoop common package
	3. "./deploy.sh hadoop" just deploy hadoop package,before this,
	   "./deploy.sh" or "./deploy.sh common " must be executed

ps: maybe you can not download protobuf-2.5.0.tar.gz, jdk-7u80-linux-x64.tar.gz and hadoop-2.7.1.tar.gz with git.
    you should install git lfs(https://help.github.com/articles/versioning-large-files/) and then git clone
    if there is also errors while install hadoop, download those package by yourself.
    
