import json
import sseclient
import datetime
import requests
from sseclient import SSEClient
from confluent_kafka import Producer
from configparser import ConfigParser


def acked(err, msg):
    if err is not None:
        print(f"Failed to deliver message: {msg.value()}: {err.str()}")


def read_config():
    config_parser = ConfigParser()
    with open('Config.ini') as fh:
        config_parser.read_file(fh)
    return config_parser


def produce_kafka_events(config_parser):
    Kafka_Producer_config = dict(config_parser['Kafka-Producer'])
    producer = Producer(Kafka_Producer_config)
    events_processed = 0
    messages = SSEClient('https://stream.wikimedia.org/v2/stream/recentchange')
    for event in messages:
        stream = json.loads(json.dumps(event.data))
        producer.produce(topic='wiki_events', key=str(events_processed),
                         value=stream, callback=acked)

        events_processed += 1
        if events_processed % 100 == 0:
            print(f"{str(datetime.datetime.now())} Flushing after {events_processed} events")
            producer.flush()


if __name__ == '__main__':
    config_parser = read_config()
    produce_kafka_events(config_parser)