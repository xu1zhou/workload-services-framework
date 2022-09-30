#!/bin/bash -e

# General setting
DEFAULT_OR_GATED=${1:-default}
WORKLOAD=${WORKLOAD:-kafka}
BACKEND=${BACKEND:-kubernetes}
TIMEOUT=${TIMEOUT:-3000}

# Kafka Setting
REPLICATION_FACTOR=${REPLICATION_FACTOR:-1}
KAFKA_BENCHMARK_TOPIC=${KAFKA_BENCHMARK_TOPIC:-KAFKABENCHMARK}
MESSAGES=${MESSAGES:-2000000}
NUM_RECORDS=${NUM_RECORDS:-3000000}
THROUGHPUT=${THROUGHPUT:-50000}
RECORD_SIZE=${RECORD_SIZE:-1000}
COMPRESSION_TYPE=${COMPRESSION_TYPE:-lz4}
CONSUMER_TIMEOUT=${CONSUMER_TIMEOUT:-600000}
# Set PARTITIONS/PRODUCERS/CONSUMERS to 0 if value is not specified by user, will update this value at runtime in run_test.sh if value is 0
PARTITIONS=${PARTITIONS:-0}
PRODUCERS=${PRODUCERS:-0}
CONSUMERS=${CONSUMERS:-0}

if [[ $DEFAULT_OR_GATED == "gated" ]]; then
    PARTITIONS=1
    PRODUCERS=1
    CONSUMERS=1
fi

# Logs Setting
DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
. "$DIR/../../script/overwrite.sh"

# Workload Setting
WORKLOAD_PARAMS="replication_factor:${REPLICATION_FACTOR};partitions:${PARTITIONS};num_records:${NUM_RECORDS};throughput:${THROUGHPUT};record_size:${RECORD_SIZE};compression_type:${COMPRESSION_TYPE}; \
    messages:${MESSAGES};producers:${PRODUCERS};consumers:${CONSUMERS};consumer_timeout:${CONSUMER_TIMEOUT}"

# Docker Setting
DOCKER_IMAGE=""
DOCKER_OPTIONS=""

# Kubernetes Setting
RECONFIG_OPTIONS="-DREPLICATION_FACTOR=${REPLICATION_FACTOR} -DPARTITIONS=${PARTITIONS} -DKAFKA_BENCHMARK_TOPIC=${KAFKA_BENCHMARK_TOPIC} \
    -DMESSAGES=${MESSAGES} -DNUM_RECORDS=${NUM_RECORDS} -DTHROUGHPUT=${THROUGHPUT} -DRECORD_SIZE=${RECORD_SIZE} -DCOMPRESSION_TYPE=${COMPRESSION_TYPE} \
    -DPRODUCERS=${PRODUCERS} -DCONSUMERS=${CONSUMERS} -DCONSUMER_TIMEOUT=${CONSUMER_TIMEOUT}"

# Used for log collection
JOB_FILTER="job-name=benchmark"

. "$DIR/../../script/validate.sh"
