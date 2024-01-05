#!/usr/bin/bash
curl https://repo1.maven.org/maven2/com/ververica/flink-sql-connector-postgres-cdc/2.4.2/flink-sql-connector-postgres-cdc-2.4.2.jar \
    -o /opt/flink/lib/flink-sql-connector-postgres-cdc.jar

curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.14.4/flink-sql-connector-kafka_2.11-1.14.4.jar \
    -o /opt/flink/lib/flink-sql-connector-kafka.jar

jobmanager.sh start-foreground
