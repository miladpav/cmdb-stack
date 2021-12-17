#!/bin/bash

## download cmdb-stack.zip
## unzip cmdb-stack.zip
## cd cmdb-stack

## docker network create --driver bridge --opt encrypted ansible-net
## docker-compose build
## docker-compose up -d

## mkdir ssh-keys
## ssh-keygen -t rsa -b 4096 -f ssh-keys/root-id_rsa -N ''
## ssh-copy-id -i ssh-keys/root-id_rsa root@Servers
## add servers ip to agent-hosts inventory file with [agent] group

## insatll agent on servers
docker exec ansible \
ansible-playbook -i /inventory/agent-hosts \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
-e yourDomain=192.168.40.135 \
/playbooks/tmway-agent/agent_install.yml

## gather facts from servers
docker exec ansible \
ansible-playbook -i /inventory/hosts.ini \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
/plays/gather-facts/gather-facts.yml

## create cmdb templates
docker exec cmdb \
ansible-cmdb -d -C /template/custom-columns.conf \
-t html_fancy_split -p local_js=0 \
--columns name,groups,main_ip,fqdn,all_ipv4,os,kernel,arch,virt,vcpus,cpu_type,ram,mem_usage,disk_usage,timestamp,prodname \
/facts/