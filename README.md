# <center>Ansible CMDB docker-compose</center>

Efficient way for using <a href="https://github.com/fboender/ansible-cmdb" ><b><i>ansible-cmdb</i></b></a> by Ferry Boender 2017.

## steps

### Usage:
If you already have ansible provision you just need to use your private key and inventory to connect to servers for gathering facts.

You can use commands.sh structure, its simple.

download latest release of this repo and follow steps on commands.sh:
```download-steps
wget https://github.com/miladpav/cmdb-stack/archive/refs/heads/master.zip
unzip master.zip
cd cmdb-stack-master
```

docker steps:
```docker-steps
docker network create --driver bridge --opt encrypted ansible-net
docker-compose build
docker-compose up -d
```

If you already have `ansible` infrastructure you can use your own private key and inventory. otherwise you should follow below steps.
```ssh-key-steps
ssh-keygen -t rsa -b 4096 -f ./ssh-keys/root-id_rsa -N ''
#ssh-copy-id -i ./ssh-keys/root-id_rsa root@Servers
## add servers ip to agent-hosts inventory file with [agent] group
#echo "servers_ip" >> ./inventory/agent-hosts
```

use ip address or domain name of docker host. example here: `docker-server=192.168.40.135`
after you have access to servers from ansible container keep going with below commands:

```install-agent-steps
docker exec ansible ansible-playbook -i /inventory/agent-hosts \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa -e yourDomain=192.168.40.135 \
/playbooks/tmway-agent/agent_install.yml
```

```gather-facts-steps
docker exec ansible ansible-playbook -i /inventory/hosts.ini \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
/playbooks/gather-facts/gather-facts.yml
```

```create-cmdb-html-steps
docker exec cmdb \
ansible-cmdb -d -C /template/custom-columns.conf \
-i /inventory/hosts.ini -t html_fancy_split -p local_js=0 \
--columns name,groups,main_ip,fqdn,all_ipv4,os,kernel,arch,virt,vcpus,cpu_type,ram,mem_usage,disk_usage,timestamp,prodname \
/facts/
```

### what does do this project?
Gathering infrastructure information are challenging specially on large scale assets. CMDB definition can help us to keep our information in centralized database or file 