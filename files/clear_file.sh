#!/bin/bash

HADOOP_INSTALL=${1}
HADOOP_TMP_DIR="/tmp/hadoopTmpDir"

if [ -d "${HADOOP_INSTALL}" ]; then
        rm -r ${HADOOP_INSTALL}
fi

if [ -d "${HADOOP_TMP_DIR}" ]; then
        rm -r ${HADOOP_TMP_DIR}
fi
