# Chinook

Layered Terraform & Ansible toolbox to setup a prod-ready Nomad cluster in AWS.

## Getting started

* Fill the file `inventories/host_vars/localhost.yml` to point a private key file and a public key file:

```
default_local_private_key_file: "/absolute/path/to/private_key_file"
default_local_public_key_file: "/absolute/path/to/public_key_file"
```

* Fill your env vars to allow Terraform to authenticate to AWS.
* Then deploy infrastructure, layer by layer:

```
ansible-playbook playbooks/deploy-tf-layer.yml -e layer_name=00-access-rights
ansible-playbook playbooks/deploy-tf-layer.yml -e layer_name=01-landscape
ansible-playbook playbooks/deploy-tf-layer.yml -e layer_name=02-monitor
ansible-playbook playbooks/deploy-tf-layer.yml -e layer_name=03-masters
ansible-playbook playbooks/deploy-tf-layer.yml -e layer_name=04-workers
```

* Wait a couple of minutes for all hosts to start and execute their cloudinit scripts.
* At last, let Ansible do its job:

```
ansible-playbook playbooks/configure.yml
```

## Use it

For now, all ips are stated in `inventories/*.inventory`. Landscape holds bastion hosts. 
Monitor holds Prometheus and Grafana.
Masters hold Consul and Nomad Server. Workers hold Nomad nodes.

For now, to reach services, you need to forward remote ports locally via ssh.

Have fun. Hack in peace.
