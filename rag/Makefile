

build:
	# docker system prune --all --force
	docker compose build
	docker build docker/embeddings --tag loader
	docker build docker/genai --tag genai

infra:
	docker compose up -d

topic:
	-docker exec kafka kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--create \
		--topic documentation

tables:
	docker exec pinot ./pinot/build/bin/pinot-admin.sh \
		AddTable \
		-tableConfigFile /tmp/pinot/table/config.json \
		-schemaFile /tmp/pinot/table/schema.json \
		-exec

all: build infra topic tables

loader:
	@docker run -it \
	 	--network rag_default \
		-e OPENAI_API_KEY=${OPENAI_API_KEY} \
		loader \
		python loader.py $(URL)

question:
	@docker run -it \
	 	--network rag_default \
		-e OPENAI_API_KEY=${OPENAI_API_KEY} \
		genai \
		python genai.py


