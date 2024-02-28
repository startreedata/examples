# RAG Pinot


```bash

./bin/pinot-admin.sh AddTable \
    -tableConfigFile ${PRJ}/table/config.json \
    -schemaFile ${PRJ}/table/schema.json \
    -exec


./bin/pinot-admin.sh DeleteTable \
    -tableName documentation \
    -exec

./bin/pinot-admin.sh DeleteSchema \
    -schemaName documentation \
    -exec
```