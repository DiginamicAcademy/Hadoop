#!/bin/sh
# Pré-télécharge les archives du lab dans downloads/ (reprise possible).
# Le build Docker les réutilise telles quelles (voir Dockerfile.debian).
# Versions à garder synchronisées avec les ARG du Dockerfile.
#
# Sources, par ordre de préférence : dlcdn.apache.org (CDN, versions
# courantes uniquement), miroir Huawei Cloud (archive complète, rapide),
# archive.apache.org (référence, lent). Le build revérifie chaque archive
# (tar tzf) et re-télécharge en cas de corruption.
set -eu
cd "$(dirname "$0")/.."
mkdir -p downloads
cd downloads

HADOOP_VERSION=3.3.6
HBASE_VERSION=2.5.15
ZK_VERSION=3.8.6
HIVE_VERSION=4.1.0

dl() {
  name="$1"; shift
  if [ -s "$name" ] && tar tzf "$name" >/dev/null 2>&1; then
    echo ">> $name : déjà présent et valide, ignoré"
    return 0
  fi
  for url in "$@"; do
    echo ">> $name : $url"
    if curl -fSL -C - --retry 2 --retry-delay 3 -o "$name" "$url"; then
      return 0
    fi
    echo "   échec — source suivante"
  done
  echo "ERREUR : impossible de télécharger $name" >&2
  return 1
}

dl "hadoop-$HADOOP_VERSION.tar.gz" \
  "https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  "https://mirrors.huaweicloud.com/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" & p1=$!
dl "hbase-$HBASE_VERSION-hadoop3-bin.tar.gz" \
  "https://mirrors.huaweicloud.com/apache/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-hadoop3-bin.tar.gz" \
  "https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-hadoop3-bin.tar.gz" & p2=$!
dl "apache-zookeeper-$ZK_VERSION-bin.tar.gz" \
  "https://mirrors.huaweicloud.com/apache/zookeeper/zookeeper-$ZK_VERSION/apache-zookeeper-$ZK_VERSION-bin.tar.gz" \
  "https://archive.apache.org/dist/zookeeper/zookeeper-$ZK_VERSION/apache-zookeeper-$ZK_VERSION-bin.tar.gz" & p3=$!
dl "apache-hive-$HIVE_VERSION-bin.tar.gz" \
  "https://mirrors.huaweicloud.com/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz" \
  "https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz" & p4=$!

fail=0
wait "$p1" || fail=1
wait "$p2" || fail=1
wait "$p3" || fail=1
wait "$p4" || fail=1
[ "$fail" -eq 0 ] || exit 1
echo "Archives prêtes dans downloads/ — le prochain build les utilisera."
