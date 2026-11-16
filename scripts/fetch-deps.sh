#!/bin/sh
# Pré-télécharge les 4 archives du lab dans downloads/, en parallèle
# (reprise possible avec -C -). Le build Docker les réutilise telles quelles
# si elles sont présentes et valides (voir Dockerfile.debian) ; sinon il
# télécharge comme avant.
# Versions à garder synchronisées avec les ARG du Dockerfile.
set -eu
cd "$(dirname "$0")/.."
mkdir -p downloads
cd downloads

HADOOP_VERSION=3.3.6
HBASE_VERSION=2.5.15
ZK_VERSION=3.8.6
HIVE_VERSION=4.1.0

dl() {
    curl -fSL -C - --retry 3 -O "$1"
}

dl "https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" & p1=$!
dl "https://dlcdn.apache.org/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-hadoop3-bin.tar.gz" & p2=$!
dl "https://dlcdn.apache.org/zookeeper/zookeeper-$ZK_VERSION/apache-zookeeper-$ZK_VERSION-bin.tar.gz" & p3=$!
# Hive 4.1.0 n'est plus sur dlcdn : archive.apache.org (lent, d'où l'intérêt de ce script)
dl "https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz" & p4=$!

fail=0
wait "$p1" || fail=1
wait "$p2" || fail=1
wait "$p3" || fail=1
wait "$p4" || fail=1
[ "$fail" -eq 0 ]

echo "Archives prêtes dans downloads/ — le prochain build les utilisera."
