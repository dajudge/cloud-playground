FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install kafka-python

ADD consumer.py /

CMD ["python3", "/consumer.py"]