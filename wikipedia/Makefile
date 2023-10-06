
services:
	brew services start zookeeper
	brew services start kafka
	brew services start pinot

	sleep 45

create:
	pinot-admin AddTable \
		-tableConfigFile table.config.json \
		-schemaFile schema.json \
		-exec

	sleep 5

drop:
	pinot-admin DeleteTable -tableName wiki -exec
	pinot-admin DeleteSchema -schemaName wiki -exec

start: services create

recreate: drop create

stop:
	brew services stop pinot
	brew services stop kafka
	brew services stop zookeeper
