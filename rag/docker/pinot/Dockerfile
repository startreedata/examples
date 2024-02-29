FROM maven:3.6.3-jdk-11

RUN apt-get update -y
RUN git clone https://github.com/apache/pinot
RUN cd pinot && mvn clean install -DskipTests -Pbin-dist

CMD [ "./pinot/build/bin/quick-start-batch.sh" ]
