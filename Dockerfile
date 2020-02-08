ARG LANGUAGETOOL_VERSION=4.8

FROM debian:buster as build

ENV DEBIAN_FRONTEND=noninteractive

ARG LANGUAGETOOL_VERSION

RUN apt-get update \
    && apt-get install -y \
    unzip \
    wget

RUN wget https://languagetool.org/download/LanguageTool-${LANGUAGETOOL_VERSION}.zip && \
    unzip LanguageTool-${LANGUAGETOOL_VERSION}.zip -d /dist

FROM openjdk:11-jre-slim-buster

RUN apt-get update \
    && apt-get install -y \
        bash \
        libgomp1

ARG LANGUAGETOOL_VERSION

COPY --from=build /dist .

WORKDIR /LanguageTool-${LANGUAGETOOL_VERSION}

RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg

RUN adduser --system --group languagetool

COPY --chown=languagetool start.sh start.sh

COPY --chown=languagetool config.properties config.properties

USER languagetool

CMD [ "bash", "start.sh" ]

EXPOSE 8010
