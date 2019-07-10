# Deploying InterSCity

Ansible scripts to deploy InterSCity.

# Requirements

## Your machine

* Install Python 2.7
  * Most Linux distributions have python installed natively. To test, 
  run on terminal: ```python --version```
* [Install ansible](http://docs.ansible.com/ansible/intro_installation.html)
* [Install pip](https://pip.pypa.io/en/stable/installing/)
  * You can install pip using: ```easy_install pip```
* Install ansible extra modules:
  * RVM: `sudo ansible-galaxy install rvm_io.rvm1-ruby`

## Remote hosts - Managed nodes:

* Debian Stretch
* Each host should be able to access the other through the network
* In each managed node, pointed by [hosts](ansible/hosts), you need to
communicate via **ssh** :
  * Install python 2.4 or later
  * Install easy_install (provided by `python-setuptools` package)
  * Run open-ssh
  * Enable your user to run commands as sudo without request password
  * Add you ssh public key to your user in remote hosts. [Here's an
  example](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)

# Configuration

* Change [ansible/hosts](ansible/hosts) file to put your hosts IPs and SSH settings
  * There you'll find a section called `[all:vars]`, then make sure the following matches:
    * `kong` should have the local IP address of `gateway-machine`
    * `rabbitmq` should have the loacal IP address of `big-machine-1`
    * `mongo` should have the loacal IP address of `big-machine-2`
    * `postgresql_host` should have the loacal IP address of `big-machine-1`

# Running

* Enter in [ansible](ansible) directory
* Run:
```sh
ansible-playbook site.yml
```

## Docker Swarm (under development)

There is a WIP for deploying the platform to Docker Swarm in order to improve reliability and make the deployments and releases easier. It is still incomplete but you can check below a preview of the requirements, configuration and release steps for this deployment alternative.

### Requirements

* At least one host, but two or more are recommended
* Operating System
  - GNU/Linux Debian Stretch
* Host requirements
  - **SSH** access
  - Add you ssh public key to your user in remote hosts. [Here's an example](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
  - passwordless sudo permission
  - **Python** must be installed
* The machine which will perform the deployment must have Ansible 2.7 or greater installed

### Configuration

1. Create your `hosts` file
  * You can check an example (here)[ansible/vagrant_hosts]
  * Each host must have a unique `swarm_node_name` variable defined
  * You'll use this variable to set the node label under `swarm_labels` variable defined for the `swarm-manager` group
  * Valid labels are
    - `gateway` (at least one host must have this label)
    - `data` (at least one host must have this label)
    - `common`
  * It is important that at least one host is in each of the following groups: `swarm-manager`; and `swarm-data-workers`
  * The remaining hosts must be members of the `swarm-workers` group
2. Install Docker Swarm
  * Within the ansible directory run: `ansible-playbook setup-swarm.yml`

### Deployment

Within the ansible directory run: `ansible-playbook deploy-swarm-stack.yml`

### Removing services

The `kong-docs` is supposed to be a one-shot service. If you want to remove it after it successfully runs, you can log in the swarm manager and run: `sudo docker service remove interscity-platform_kong-docs`

# Development

The following instructions are relevant for developers and maintainer of the deployment scripts here. If you are interested only on running an instance of the platform follow the steps at the beginning of this file.

## Additional requirements

* 5GB of RAM available
* 20GB of disk
* Vagrant
  * VirtualBox

## Deploying locally

* `vagrant up`
* SSH into each of the nodes and add them to your `known_hosts` files
  * `ssh -i ~/.vagrant.d/insecure_private_key vagrant@10.10.10.100`
  * `ssh -i ~/.vagrant.d/insecure_private_key vagrant@10.10.10.101`
  * `ssh -i ~/.vagrant.d/insecure_private_key vagrant@10.10.10.102`
  * `ssh -i ~/.vagrant.d/insecure_private_key vagrant@10.10.10.103`
  * `ssh -i ~/.vagrant.d/insecure_private_key vagrant@10.10.10.104`
* Enter in [ansible](ansible) directory
* `ansible-playbook -i vagrant_hosts site.yml`
