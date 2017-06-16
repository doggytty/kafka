#!/bin/sh

# ${KAFKA_HOME} 当前的kafka安装目录
# ${SCALA_VERSION} kafka使用的scala版本
# ${KAFKA_VERSION} kafka自身版本

echo "part 0: persistent dir...."
export RESET=${RESET:-0}
if [ ${RESET} -eq 0 ]; then
    rm -f /data
fi

mkdir -p /data/kafka-logs
mkdir -p /data/zookeeper

# part 1 config
echo "part 1: now compare config...."

# consumer.properties
export ZK_ADDRESS=${ZK_ADDRESS:-}
if [ -z ${ZK_ADDRESS} ]; then
    echo "==> ZK_ADDRESS is null, exit 1"
    exit 1
fi
echo "==> ZK_ADDRESS: ${ZK_ADDRESS}"

export ZK_TIMEOUT=${ZK_TIMEOUT:-6000}
echo "==> ZK_TIMEOUT: ${ZK_TIMEOUT}"

export CONSUMER_TIMEOUT=${CONSUEMR_TIMEOUT:-5000}
echo "==> CONSUMER_TIMEOUT: ${CONSUMER_TIMEOUT}"

export CONSUMER_GROUP=${CONSUMER_GROUP:-"consumer-group"}
echo "==> CONSUMER_GROUP: ${CONSUMER_GROUP}"

# producer.properties
export BOOTSTRAP_SERVERS=${BOOTSTRAP_SERVERS:-"localhost:9092"}
echo "==> BOOTSTRAP_SERVERS:  ${BOOTSTRAP_SERVERS}"
#export COMPRESSION_TYPE=${COMPRESSION_TYPE:-none}
#echo "==> COMPRESSION_TYPE: ", ${COMPRESSION_TYPE}

# server.properties
export BROKER_ID=${BROKER_ID:-}
if [ -z ${BROKER_ID} ]; then
    echo "==> BROKER_ID is null, exit 1"
    exit 1
fi
echo "==> BROKER_ID: ${BROKER_ID}"

export LOG_DIRS=${LOG_DIRS:-"/data/kafka-logs"}
echo "==> LOG_DIRS: ${LOG_DIRS}"

# zookeeper.properties
export DATA_DIR=${DATA_DIR:-"/data/zookeeper"}
echo "==> DATA_DIR: ${DATA_DIR}"

echo "part 1: now compare config ok"

# part 2 replace variable
echo "part 2: config variable replace..."
KAFKA_CONFIG=${KAFKA_HOME}/config
echo "kafka config path: ${KAFKA_CONFIG}"

# consumer.properties
echo "consumer.properties"
# ZK_TIMEOUT\ZK_ADDRESS\CONSUMER_TIMEOUT\CONSUMER_GROUP
sed -i \
    -e "s|{ZK_TIMEOUT}|${ZK_TIMEOUT}|" \
    -e "s|{ZK_ADDRESS}|${ZK_ADDRESS}|" \
    -e "s|{CONSUMER_TIMEOUT}|${CONSUMER_TIMEOUT}|" \
    -e "s|{CONSUMER_GROUP}|${CONSUMER_GROUP}|" \
    ${KAFKA_CONFIG}/consumer.properties

# producer.properties
echo "producer.properties"
# BOOTSTRAP_SERVERS
sed -i \
    -e "s|{BOOTSTRAP_SERVERS}|${BOOTSTRAP_SERVERS}|" \
    ${KAFKA_CONFIG}/producer.properties

# server.properties
echo "server.properties"
# BROKER_ID\LOG_DIRS\ZK_ADDRESS\ZK_TIMEOUT
sed -i \
    -e "s|{BROKER_ID}|${BROKER_ID}|" \
    -e "s|{LOG_DIRS}|${LOG_DIRS}|" \
    -e "s|{ZK_ADDRESS}|${ZK_ADDRESS}|" \
    -e "s|{ZK_TIMEOUT}|${ZK_TIMEOUT}|" \
    ${KAFKA_CONFIG}/server.properties

# server.properties
echo "server.properties"
# BROKER_ID\LOG_DIRS\ZK_ADDRESS\ZK_TIMEOUT
sed -i \
    -e "s|{BROKER_ID}|${BROKER_ID}|" \
    -e "s|{LOG_DIRS}|${LOG_DIRS}|" \
    -e "s|{ZK_ADDRESS}|${ZK_ADDRESS}|" \
    -e "s|{ZK_TIMEOUT}|${ZK_TIMEOUT}|" \
    ${KAFKA_CONFIG}/server.properties

# zookeeper.properties
echo "zookeeper.properties"
# DATA_DIR
sed -i \
    -e "s|{DATA_DIR}|${DATA_DIR}|" \
    ${KAFKA_CONFIG}/zookeeper.properties

echo "part 3: now start kafka...."
cd ${KAFKA_HOME}

if [[ "$1" = "sh" ]]; then
    /bin/sh
elif [[ "$1" = "start" ]]; then
    $2 config/server.properties
elif [[ "$1" = "custom" ]]; then
    $2 $3
else
    kafka-server-start.sh config/server.properties
fi


