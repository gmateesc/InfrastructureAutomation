FROM agt/centos-java:latest
MAINTAINER Gabriel Mateescu "gabriel.mateescu@gmail.com"

# Import the GPG key
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# Create repository file for ElasticSearch
RUN echo $'[elasticsearch-2.x]\n\
name=Elasticsearch repository for 2.x packages\n\
baseurl=https://packages.elastic.co/elasticsearch/2.x/centos\n\
gpgcheck=1\n\
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch\n\
enabled=1\n\
' > /etc/yum.repos.d/elasticsearch.repo 

# Install ElasticSearch
RUN yum install -y install -y elasticsearch


