#!/bin/bash

CONF_DIR=${HBASE_CONF_DIR:-/opt/hbase/conf}

for host in $(grep -v '^#' "$CONF_DIR/regionservers"); do
    echo "[INFO] Stopping HBase Thrift on $host..."
    if ! ssh "$host" "bash -lc '/opt/hbase/bin/hbase-daemon.sh stop thrift'"; then
        echo "[WARN] Unable to stop Thrift on $host"
    fi
done

echo "[INFO] Stopping HBase Thrift on hadoop-master..."
/opt/hbase/bin/hbase-daemon.sh stop thrift
