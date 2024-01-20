#!/bin/bash

sleep 30

kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create \
    --topic customer_sink \
    --config "cleanup.policy=compact"

kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create \
    --topic rental_sink \
    --config "cleanup.policy=compact"

kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create \
    --topic obt \
    --config "cleanup.policy=compact"