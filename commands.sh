#!/bin/bash

## insatll agent on servers
docker exec ansible \
ansible-playbook -i /plays/tmway_agent/hosts \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
/plays/tmway_agent/agent_install.yml

## gather facts from servers
docker exec ansible \
ansible -i /inventory/hosts.ini all \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
-m setup --tree /facts

## create cmdb templates
docker exec cmdb \
ansible-cmdb -d -C /template/custom-columns.conf \
-t html_fancy_split -p local_js=0 \
--columns name,groups,main_ip,fqdn,all_ipv4,os,kernel,arch,virt,vcpus,cpu_type,ram,mem_usage,disk_usage,timestamp,prodname \
/facts/