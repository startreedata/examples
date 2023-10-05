# Wikipedia

```mermaid
flowchart LR

Python-->Kafka-->Pinot
```

## Homebrew Kafka Formulae
In this exmample, we're going to run a local Kafka cluster that was installed using `brew` on MacOS.

```bash
brew install kafka
# brew upgrade kafka
```

If you already have brew Kafka installed, then to ensure Kafka starts up fresh, delete the file below so that Kafka doesn't think it's trying to join a differen cluster ID. You may need to do this every time you restart Kafka.

```bash
rm /usr/local/var/lib/kafka-logs/meta.properties
```

Configure the `server.properties` file if needed for security. Otherwise, you should not need to edit this file.
```bash
vim /usr/local/etc/kafka/server.properties
```

Start Kafka

```bash
brew services start zookeeper
brew services start kafka
# brew services restart kafka # to restart
```

Tail the log
```bash
tail -f /usr/local/var/log/kafka/kafka_output.log
```

Then verify that Kafka is listening

```bash
nc -v localhost 9092
```

Now create a topic in Kafka.

```bash
kafka-topics --bootstrap-server localhost:9092 --create --topic wiki
```

## Homebrew Pinot Formulae
In this exmample, we're going to run a local Pinot cluster that was also installed using `brew` on MacOS.

```bash
brew install pinot
```

Tail the Pinot logs.

```bash
tail -f /usr/local/var/log/pinot/pinot_output.log
```

## Pinot Table

Below is a sample message in Kafka.

```json
{
"title": "Puerto Rico statehood movement",
"title_detail": {
    "type": "text/plain",
    "language": null,
    "base": "https://en.wikipedia.org/w/api.php?action=feedrecentchanges",
    "value": "Puerto Rico statehood movement"
},
"links": [
    {
        "rel": "alternate",
        "type": "text/html",
        "href": "https://en.wikipedia.org/w/index.php?title=Puerto_Rico_statehood_movement&diff=1178445562&oldid=1175414997"
    }
],
"link": "https://en.wikipedia.org/w/index.php?title=Puerto_Rico_statehood_movement&diff=1178445562&oldid=1175414997",
"id": "https://en.wikipedia.org/w/index.php?title=Puerto_Rico_statehood_movement&diff=1178445562&oldid=1175414997",
"guidislink": false,
"summary": "HTML GOES IN HERE",
"summary_detail": {
    "type": "text/html",
    "language": null,
    "base": "https://en.wikipedia.org/w/api.php?action=feedrecentchanges",
    "value": "HTML GOES IN HERE"
},
"published": "Tue, 03 Oct 2023 18:31:50 GMT",
"published_parsed": [
    2023,
    10,
    3,
    18,
    31,
    50,
    1,
    276,
    0
],
"authors": [
    {
        "name": "217.26.199.96"
    }
],
"author": "217.26.199.96",
"author_detail": {
    "name": "217.26.199.96"
},
"comments": "https://en.wikipedia.org/wiki/Talk:Puerto_Rico_statehood_movement"
}

```
This sample document looks complex but we can automatically infer the schema by running the `JsonToPinotSchema` tool.

### Infer the Schema

```bash
# download docker compose
curl https://raw.githubusercontent.com/startreedata/pinot-recipes/main/recipes/infer-schema-json-data/docker-compose.yml --output docker-compose.yml

# create a directory for the output schema to be written
mkdir config

# run the infer tool JsonToPinotSchema
docker run \
    -v ${PWD}/sample.json:/data/sample.json \
    -v ${PWD}/config:/config \
    apachepinot/pinot:latest JsonToPinotSchema \
    -jsonFile /data/sample.json \
    -pinotSchemaName="wiki" \
    -outputDir="/config" \
    -dimensions=""
```

The schema will appear in the `config` directory. You'll need to modify it to add a timestamp. Delete the `published` field and append this to the end of the schema.

```json
   ,"dateTimeFieldSpecs": [{
      "name": "published_mil",
      "dataType": "LONG",
      "format": "EPOCH",
      "granularity": "1:SECONDS"
  }]
```

The final schema can be seen [here](./schema.json)

### Table Config

Next we need to define the table in Pinot. Below is the complete configuration we will use. Let's go over the important parts.

```json
{
    "tableName": "wiki",
    "tableType": "REALTIME",
    "segmentsConfig": {
      "timeColumnName": "published_mil",
      "timeType": "SECONDS",
      "schemaName": "wiki",
      "replicasPerPartition": "1"
    },
    "ingestionConfig": {
      "complexTypeConfig": {
        "delimeter": "."
      },
      "transformConfigs": [{
        "columnName": "published_mil",
        "transformFunction": "fromDateTime(published, 'EE, dd MMM yyyy HH:mm:ss zzz')"
      }]
    },
    "tenants": {},
    "tableIndexConfig": {
      "loadMode": "MMAP",
      "streamConfigs": {
        "streamType": "kafka",
        "stream.kafka.consumer.type": "lowlevel",
        "stream.kafka.topic.name": "wiki",
        "stream.kafka.decoder.prop.format": "JSON",
        "stream.kafka.decoder.class.name": "org.apache.pinot.plugin.stream.kafka.KafkaJSONMessageDecoder",
        "stream.kafka.consumer.factory.class.name": "org.apache.pinot.plugin.stream.kafka20.KafkaConsumerFactory",
        "stream.kafka.broker.list": "localhost:9092",
        "realtime.segment.flush.threshold.time": "3600000",
        "realtime.segment.flush.threshold.rows": "50000",
        "stream.kafka.consumer.prop.auto.offset.reset": "smallest"
      }
    },
    "metadata": {
      "customConfigs": {}
    }
}
```

The `tableName` needs to be the same as the `schemaName` in `schema.json`.
```json
"tableName": "wiki",
```

Since we are consuming from Kafka, we set the property `tableType` to `REALTIME`.
```json
"tableType": "REALTIME",
```

Pinot distributes data by breaking the data into smaller chunks known as segments (similar to shards/partitions in relational databases). Segments are time-based partitions.
The `segmentsConfig` 

```json
    "segmentsConfig": {
      "timeColumnName": "published_mil",
      "timeType": "SECONDS",
      "schemaName": "wiki",
      "replicasPerPartition": "1"
    },
```

#### Ingestion Config
In the sample message, the `published` field is formatted in such a way that Pinot cannot consume it to propery complete and create new segments. Also, the message has complex types in it that Pinot need to be aware of.

```json
    "ingestionConfig": {
      "complexTypeConfig": {
        "delimeter": "."
      },
      "transformConfigs": [{
        "columnName": "published_mil",
        "transformFunction": "fromDateTime(published, 'EE, dd MMM yyyy HH:mm:ss zzz')"
      }]
    },
```

The `delimeter` is applied in a transformation as the data is ingested into Pinot. Pinot will use `.` in the column name to indicate the levels in the JSON message.

The `transformFunction` transforms this timestamp format in `published` `Tue, 03 Oct 2023 18:31:50 GMT` into milliseconds and sets it as the value in a new field called `published_mil`.

### Pinot CLI

Create table

```bash
pinot-admin AddTable \
    -tableConfigFile table.config.json \
    -schemaFile schema.json \
    -exec
```

Delete table

```bash
pinot-admin DeleteTable -tableName wiki -exec
```

```bash
pinot-admin DeleteSchema -schemaName wiki -exec
```

## Produce to Kafka
This application reads a RSS feed of Wikipedia page changes and sends them to Kafka.

https://en.wikipedia.org/w/api.php?action=feedrecentchanges

```bash
python kafka.py
```

## Execute Qeury

```sql
select author, title, count(*) changes from wiki
group by author, title
order by changes desc
```

```sql
select author, title, count(title) OVER(PARTITION BY author) changes
from wiki
```
