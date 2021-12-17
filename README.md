# Ansible CMDB docker-compose

Efficient way to use edited <a href="https://github.com/miladpav/ansible-cmdb" ><b><i>ansible-cmdb</i></b></a> from main source of <a href="https://github.com/fboender/ansible-cmdb" >Ferry Boender</a> 2017.

- [What is this project](https://github.com/miladpav/cmdb-stack#What-is-this-project)
- [How to Use](https://github.com/miladpav/cmdb-stack#How-to-use-and-Why)

## Architecture
![Architecture](pictures/architecture.jpg)

### How to use and Why:
To straight using of commands you can go for [commands.sh](commands.sh) file and follow actions.

##### Download Repo
download latest release of this repo:
```download-steps
wget https://github.com/miladpav/cmdb-stack/archive/refs/heads/master.zip
unzip master.zip
cd cmdb-stack-master
```

##### Docker Requirements
this stack needs docker host and docker-compose command to serve services:
```docker-steps
docker network create --driver bridge --opt encrypted ansible-net
docker-compose build
docker-compose up -d
```

##### Prepare ssh-key
If you already have `ansible` infrastructure you can use your own private key and inventory. otherwise you should follow below steps.
```ssh-key-steps
ssh-keygen -t rsa -b 4096 -f ./ssh-keys/root-id_rsa -N ''
#ssh-copy-id -i ./ssh-keys/root-id_rsa root@Servers
## add servers ip to agent-hosts inventory file with [agent] group
#echo "servers_ip" >> ./inventory/agent-hosts
```

##### Auto Inventory Generator

The next step is to install the tmway agent.

the key of keep assets updated is to use tmway, this is an auto inventory generator for ansible, you can read about it on:
[https://github.com/miladpav/Tell-Me-Who-Are-You](https://github.com/miladpav/Tell-Me-Who-Are-You)

> ***__Notice:__*** I suggest to you add [agent.sh](playbooks/tmway-agent/files/agent.sh) end of your terraform provisioning or OVF Templates for virtual machines to keep your ansible inventory update without any handy actions.
> ```notice-steps
> cat > /etc/cron.d/tmway-agent << EOF
> 0 */6 * * * root /home/scripts/agent.sh http://yourDomain:4040/tmway
> EOF
> ```

You just need to run [agent_install.yml playbook](playbooks/tmway-agent/agent_install.yml) on your servers via ansible.

Use ip address or domain name of docker host. example here: `docker-server=192.168.40.135`
```install-agent-steps
docker exec ansible ansible-playbook -i /inventory/agent-hosts \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa -e yourDomain=192.168.40.135 \
/playbooks/tmway-agent/agent_install.yml
```

##### Gather Facts
If prior playbook runs successfully, new inventory has been generated automatically in `inventory/hosts.ini` then we can gather data from this inventory

You can add this command to cron to keep update your data every day. example crontab-time: `0 02 * * *`
```gather-facts-steps
docker exec ansible ansible-playbook -i /inventory/hosts.ini \
-e ansible_ssh_private_key_file=/ssh-keys/root-id_rsa \
/playbooks/gather-facts/gather-facts.yml
```
> ***__Notice:__*** If you want add your custom data to cmdb or facts you can enable custom facts scripts to playbook like comment examples in [gather-facts.yml](playbooks/gather-facts/gather-facts.yml)
> ```notice-steps
> cat > playbooks/gather-facts/files/TEST.fact << EOF
> #!/bin/bash
> echo '{"CURRENT_TIME": "$(date)"}'
> EOF
> ```

##### Create CMDB
By running the previous command we have facts files from servers in the `facts/` directory, then we can create HTML files from these facts via ansible-cmdb.

You can add this command to cron to keep updating HTML every day. example crontab-time:`0 03 * * *`

```create-cmdb-html-steps
docker exec cmdb \
ansible-cmdb -d -C /template/custom-columns.conf \
-i /inventory/hosts.ini -t html_fancy_split -p local_js=0 \
--columns name,groups,main_ip,fqdn,all_ipv4,os,kernel,arch,virt,vcpus,cpu_type,ram,mem_usage,disk_usage,timestamp,prodname \
/facts/
```
By using [template](template/custom-columns.conf) we can create more customized data and columns to our CMDB equals to custom facts gathered by ansible or other gathered facts not shown on the first page of cmdb.
References:
  - [mako-template](https://www.makotemplates.org/)
  - [jsonxs](https://github.com/fboender/jsonxs) 


##### Result
At the end of the compose file, we already mount cmdb HTML files into the Nginx container, Therefore we can see the final result on our web server.

![Result](pictures/cmdb-output.jpg)

### What is this project?
Gathering infrastructure information is challenging especially on large-scale assets. CMDB definition can help us to keep our information in a centralized database or file updated. Thanks to Ferry Boender for the amazing [ansible-cmdb](https://github.com/fboender/ansible-cmdb) repo we can use ansible to gather servers information more effectively and combine it with some actions to do it fully automatically. Of course, we have better solutions on cloud-native infrastructure, but in case we cannot access clouds or any similar infrastructure we can use this repo.

So I prepared this repo to use easily and semi-auto to keep the server's information updated. little edits on the main project of ansible-cmdb and writing the tmway flask app are some of my actions to able use the ansible-cmdb feature more efficient.

One of the best features of this repo is we can add our needs data definitions everywhere of our work timeline using the powerful feature of [ansible-custom-facts](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html#id8) and with [mako-template](https://www.makotemplates.org/) we can add our customized facts by ansible in cmdb.
for detail of using [cmdb templates](template/custom-columns.conf) you can use [full documention](https://ansible-cmdb.readthedocs.io/en/latest/) of ansible-cmdb.