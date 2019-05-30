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
