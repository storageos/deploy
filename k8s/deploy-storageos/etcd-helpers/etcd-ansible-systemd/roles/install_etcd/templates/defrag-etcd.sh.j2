#!/bin/bash

set -e

function usage {
    echo -e "Usage:\t $0 [-u http://myetcd:2379 -r]"
    echo -e "  -h \t Display this help message."
    echo -e "  -r \t Add a randomness delay to the operation to avoid different etcd members to defrag at the same time"
    echo -e "  -u \t Etcd URL endpoint (default: http://localhost:2379)"
}

while getopts ":hru:" opt; do
  case ${opt} in
    h )
      usage
      exit 0
      ;;
    r )
      randomness=1
      ;;
    u )
      url=$OPTARG
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

url=${url-"http://localhost:2379/metrics"}
current_size_metric="etcd_mvcc_db_total_size_in_bytes" 
db_size_metric="etcd_server_quota_backend_bytes"
etcdctl_cmd="ETCDCTL_API=3 etcdctl --endpoints $url"

current_size=$(eval $etcdctl_cmd endpoint status -wjson  | egrep -o '"dbSize":[0-9]*' | egrep -o '[0-9]*')
db_size=$(curl -s "$url" | grep -v "^#" | grep "$db_size_metric" | awk '{print $2}') 

if [ -z "$current_size" ] || [ -z "$db_size" ]; then
    echo "Couldn't find the metrics from the Prometheus endpoint"
    exit 1
fi

# Convert scientific notation to bytes
db_size=$(printf %0.0f\\n "$db_size")

used=$(echo "scale=2 ; $current_size / $db_size * 100" | bc | cut -d. -f1)
echo "`date "+%Y-%d-%mT%H:%M:%S"` -- Percentage used of the DB $used%"

if [ $used -gt 80 ]; then
    echo "Current size: $current_size"
    echo "DB size: $db_size"
    echo "The endpoint needs defragmenting, used: $used"
    echo "`date "+%Y-%d-%mT%H:%M:%S"` -- Triggering a defrag"
    if [ -z "$randomness" ]; then
        # Span of 0-10min of waiting time
        span=$(( RANDOM % 600 ))
        echo $span
        sleep $span
    fi
    eval $etcdctl_cmd defrag
fi

echo "`date "+%Y-%d-%mT%H:%M:%S"` -- Defrag check finished"
echo
