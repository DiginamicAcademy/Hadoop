@echo off
REM Pré-télécharge les 4 archives du lab dans downloads\
REM (reprise possible avec -C -). Le build Docker les réutilise telles
REM quelles si elles sont présentes et valides (voir Dockerfile.debian) ;
REM sinon il télécharge comme avant.
REM Versions à garder synchronisées avec les ARG du Dockerfile.
cd /d "%~dp0.."
if not exist downloads mkdir downloads
cd downloads

set HADOOP_VERSION=3.3.6
set HBASE_VERSION=2.5.15
set ZK_VERSION=3.8.6
set HIVE_VERSION=4.1.0

curl.exe -fSL -C - --retry 3 -O https://dlcdn.apache.org/hadoop/common/hadoop-%HADOOP_VERSION%/hadoop-%HADOOP_VERSION%.tar.gz || exit /b 1
REM HBase et ZooKeeper ne sont plus sur dlcdn (versions sorties du CDN) : archive.apache.org
curl.exe -fSL -C - --retry 3 -O https://archive.apache.org/dist/hbase/%HBASE_VERSION%/hbase-%HBASE_VERSION%-hadoop3-bin.tar.gz || exit /b 1
curl.exe -fSL -C - --retry 3 -O https://archive.apache.org/dist/zookeeper/zookeeper-%ZK_VERSION%/apache-zookeeper-%ZK_VERSION%-bin.tar.gz || exit /b 1
REM Hive 4.1.0 n'est plus sur dlcdn : archive.apache.org (lent, d'où l'intérêt de ce script)
curl.exe -fSL -C - --retry 3 -O https://archive.apache.org/dist/hive/hive-%HIVE_VERSION%/apache-hive-%HIVE_VERSION%-bin.tar.gz || exit /b 1

echo Archives pretes dans downloads\ - le prochain build les utilisera.
