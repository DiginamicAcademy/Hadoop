#!/bin/bash

CONF_DIR=${HBASE_CONF_DIR:-/opt/hbase/conf}

echo "[INFO] Starting HBase Thrift on hadoop-master..."
/opt/hbase/bin/hbase-daemon.sh start thrift -b 0.0.0.0 -p 9090

for host in $(grep -v '^#' "$CONF_DIR/regionservers"); do
    echo "[INFO] Starting HBase Thrift on $host..."
    if ! ssh "$host" "bash -lc '/opt/hbase/bin/hbase-daemon.sh start thrift -b 0.0.0.0 -p 9090'"; then
        echo "[WARN] Unable to start Thrift on $host"
    fi
done

echo "[INFO] HBase Thrift started on master + slaves."
