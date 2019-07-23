FROM debian:9-slim

RUN apt-get update -qq && apt-get install -yq \
    curl \
    vim \
    less \
    python3-pip \
    rsync

RUN pip3 install --upgrade awscli

ADD ./entrypoint.sh /entrypoint.sh
ADD ./uploader.sh /opt/uploader.sh
ADD ./syncher.sh /opt/syncher.sh
RUN chmod u+x /entrypoint.sh /opt/uploader.sh /opt/syncher.sh

CMD ["/entrypoint.sh"]
