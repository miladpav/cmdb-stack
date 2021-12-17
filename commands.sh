#!/bin/bash

## download cmdb-stack.zip
## unzip cmdb-stack.zip
## cd cmdb-stack

## docker network create --driver bridge --opt encrypted ansible-net
## docker-compose build
## docker-compose up -d

## ssh-keygen -t rsa -b 4096 -f ssh-keys/root-id_rsa -N ''
## ssh-copy-id -i ssh-keys/root-id_rsa root@Servers
## add servers ip to agent-hosts inventory file with [agent] group
## echo "192.168.40.134" >> /inventory/agent-hosts

## insatll agent on servers
docker exec ansible \
ansible-playbook -i /inventory/agent-hosts \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
-e yourDomain=192.168.40.135 \ #example: docker_server=192.168.40.135 and if you have domain you must change nginx-conf/frontend.conf
/playbooks/tmway-agent/agent_install.yml

## now your auto inventory has been created !

## gather facts from servers
docker exec ansible \
ansible-playbook -i /inventory/hosts.ini \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
/playbooks/gather-facts/gather-facts.yml

## create cmdb templates
docker exec cmdb \
ansible-cmdb -d -C /template/custom-columns.conf \
-t html_fancy_split -p local_js=0 \
--columns name,groups,main_ip,fqdn,all_ipv4,os,kernel,arch,virt,vcpus,cpu_type,ram,mem_usage,disk_usage,timestamp,prodname \
/facts/
