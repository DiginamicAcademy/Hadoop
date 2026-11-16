@echo off
REM Pré-télécharge les 4 archives du lab dans downloads\
REM (reprise possible avec -C -). Le build Docker les réutilise telles
REM quelles si elles sont présentes et valides (voir Dockerfile.debian) ;
REM sinon il télécharge comme avant.
REM Versions à garder synchronisées avec les ARG du Dockerfile.
REM Sources : dlcdn (CDN, versions courantes) puis miroir Huawei Cloud
REM (archive complète, rapide) puis archive.apache.org (référence, lent).
cd /d "%~dp0.."
if not exist downloads mkdir downloads
cd downloads

set HADOOP_VERSION=3.3.6
set HBASE_VERSION=2.5.15
set ZK_VERSION=3.8.6
set HIVE_VERSION=4.1.0

call :dl "hadoop-%HADOOP_VERSION%.tar.gz" "https://dlcdn.apache.org/hadoop/common/hadoop-%HADOOP_VERSION%/hadoop-%HADOOP_VERSION%.tar.gz" "https://mirrors.huaweicloud.com/apache/hadoop/common/hadoop-%HADOOP_VERSION%/hadoop-%HADOOP_VERSION%.tar.gz" "https://archive.apache.org/dist/hadoop/common/hadoop-%HADOOP_VERSION%/hadoop-%HADOOP_VERSION%.tar.gz" || exit /b 1
call :dl "hbase-%HBASE_VERSION%-hadoop3-bin.tar.gz" "https://mirrors.huaweicloud.com/apache/hbase/%HBASE_VERSION%/hbase-%HBASE_VERSION%-hadoop3-bin.tar.gz" "https://archive.apache.org/dist/hbase/%HBASE_VERSION%/hbase-%HBASE_VERSION%-hadoop3-bin.tar.gz" || exit /b 1
call :dl "apache-zookeeper-%ZK_VERSION%-bin.tar.gz" "https://mirrors.huaweicloud.com/apache/zookeeper/zookeeper-%ZK_VERSION%/apache-zookeeper-%ZK_VERSION%-bin.tar.gz" "https://archive.apache.org/dist/zookeeper/zookeeper-%ZK_VERSION%/apache-zookeeper-%ZK_VERSION%-bin.tar.gz" || exit /b 1
call :dl "apache-hive-%HIVE_VERSION%-bin.tar.gz" "https://mirrors.huaweicloud.com/apache/hive/hive-%HIVE_VERSION%/apache-hive-%HIVE_VERSION%-bin.tar.gz" "https://archive.apache.org/dist/hive/hive-%HIVE_VERSION%/apache-hive-%HIVE_VERSION%-bin.tar.gz" || exit /b 1

echo Archives pretes dans downloads\ - le prochain build les utilisera.
exit /b 0

:dl
set "name=%~1"
shift
if exist "%name%" (
  tar -tzf "%name%" >nul 2>&1 && (echo [skip] %name% deja present et valide & exit /b 0)
)
:try
if "%~1"=="" (echo ERREUR : impossible de telecharger %name% & exit /b 1)
echo ^>^> %name% : %~1
curl.exe -fSL -C - --retry 2 --retry-delay 3 -o "%name%" "%~1" && exit /b 0
echo    echec - source suivante
shift
goto try
