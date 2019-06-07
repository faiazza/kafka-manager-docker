FROM centos:7 AS BUILD_STAGE
ARG version=2.0.0.2
ARG http_proxy
ARG https_proxy
ARG no_proxy
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV no_proxy=${no_proxy}
RUN yum install -y java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel git wget unzip which git nodejs
RUN git clone https://github.com/yahoo/kafka-manager /kafka-manager-src
WORKDIR /kafka-manager-src
RUN git fetch --all
RUN echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt
RUN echo 'play.http.context=${?HTTP_CONTEXT}' >> ./conf/application.conf
RUN ./sbt clean dist
RUN unzip  -d / ./target/universal/kafka-manager-${version}.zip
RUN mv /kafka-manager-${version} /kafka-manager

FROM openjdk:8-jdk-alpine AS PACKAGE
RUN apk --no-cache add bash curl ca-certificates
RUN update-ca-certificates
RUN unset http_proxy && unset https_proxy && unset no_proxy
WORKDIR /usr/local/
COPY --from=BUILD_STAGE /kafka-manager ./kafka-manager
ENTRYPOINT ["/usr/local/kafka-manager/bin/kafka-manager"]
