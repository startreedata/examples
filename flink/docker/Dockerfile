FROM flink:1.18.0-scala_2.12

RUN curl https://repo1.maven.org/maven2/com/ververica/flink-sql-connector-postgres-cdc/2.4.2/flink-sql-connector-postgres-cdc-2.4.2.jar \
    -o /opt/flink/lib/flink-sql-connector-postgres-cdc.jar

RUN curl -O https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/1.17.2/flink-sql-connector-kafka-1.17.2.jar \
    -o /opt/flink/lib/flink-sql-connector-kafka.jar

