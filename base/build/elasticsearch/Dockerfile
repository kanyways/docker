FROM docker.elastic.co/elasticsearch/elasticsearch:7.6.0

MAINTAINER Jason.Wang "kzone.wang@gmail.com"

# install IK Analysis
RUN mkdir -p /usr/share/elasticsearch/plugins/ik \
    && cd /usr/share/elasticsearch/plugins/ik

ADD elasticsearch-analysis-ik-7.6.0.tar.gz /usr/share/elasticsearch/plugins/ik

HEALTHCHECK --interval=10s --timeout=5s --retries=30 --start-period=30s CMD curl -f 127.0.0.1:9200