FROM python:3.10-slim

ARG ansible_version=4.9.0

RUN apt-get update && \
    apt install -y openssh-client && \
    apt-get clean && \
    pip install ansible==$ansible_version && \
    mkdir /playbooks

WORKDIR /playbooks