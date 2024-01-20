FROM apachepinot/pinot:0.12.0

RUN ./bin/pinot-admin.sh AddTable \
    -tableConfigFile /tmp/pinot/rental.table.config.json \
    -schemaFile /tmp/pinot/rental.json \
    -exec

RUN ./bin/pinot-admin.sh AddTable \
    -tableConfigFile /tmp/pinot/customer.table.config.json \
    -schemaFile /tmp/pinot/customer.json \
    -exec
