#!/bin/local/python

import time
import feedparser
import json
import os
import logging
from dotenv import load_dotenv

from confluent_kafka import Producer

def delivery_report(err, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    # else:
    #     print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

def poll(p):
	feed=feedparser.parse('https://en.wikipedia.org/w/api.php?action=feedrecentchanges')
	entries = feed['entries']

	p.poll(0)

	for e in entries:
		j = json.dumps(e)
		p.produce(
			key=e['id'],
			topic='wiki', 
			value=j.encode('utf-8'), 
			on_delivery=delivery_report)
		
	# Wait for any outstanding messages to be delivered and delivery report
	# callbacks to be triggered.
	p.flush()

if __name__== "__main__":
	load_dotenv()
	logging.basicConfig(level=logging.INFO)
	p = Producer({'bootstrap.servers': 'localhost:9092'})

	while True:
		poll(p)
		time.sleep(1)

