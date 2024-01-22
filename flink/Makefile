
topics:
	docker exec -it kafka kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--create \
		--topic customer_sink \
		--config "cleanup.policy=compact"

	docker exec -it kafka kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--create \
		--topic rental_sink \
		--config "cleanup.policy=compact"

	docker exec -it kafka kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--create \
		--topic obt

tables: pobt prental pcustomer

pobt:
	docker exec -it pinot-controller ./bin/pinot-admin.sh AddTable \
		-tableConfigFile /tmp/pinot/obt.table.config.json \
		-schemaFile /tmp/pinot/obt.json \
		-exec

	sleep 5

prental:
	docker exec -it pinot-controller ./bin/pinot-admin.sh AddTable \
		-tableConfigFile /tmp/pinot/rental.table.config.json \
		-schemaFile /tmp/pinot/rental.json \
		-exec

	sleep 5

pcustomer:
	docker exec -it pinot-controller ./bin/pinot-admin.sh AddTable \
		-tableConfigFile /tmp/pinot/customer.table.config.json \
		-schemaFile /tmp/pinot/customer.json \
		-exec

	sleep 5

dvdrental:
	docker exec -it postgres psql -h localhost -U postgres -f /tmp/scripts/init.sql
	sleep 5
	docker exec -it postgres pg_restore -h localhost -U postgres -d dvdrental /tmp/data/dvdrental.tar
	sleep 5
	docker exec -it postgres psql -h localhost -U postgres -d dvdrental -f /tmp/scripts/cdc.sql
	sleep 5

streams: obt dims

dims:
	docker exec -it jobmanager ./bin/sql-client.sh -l lib -f /tmp/scripts/flink.dims.sql

obt:
	docker exec -it jobmanager ./bin/sql-client.sh -l lib -f /tmp/scripts/flink.obt.sql


all: topics tables dvdrental streams

