# Deploying InterSCity on Revoada

This repository contains the Ansible scripts to deploy InterSCity on IME's cloud
infrastructure - Revoada.

## Setup:

* Install Python 2.7
  * Most Linux distributions have python installed natively. To test, 
  run on terminal: ```python --version```
* [Install ansible](http://docs.ansible.com/ansible/intro_installation.html)
* [Install pip](https://pip.pypa.io/en/stable/installing/)
  * You can install pip using: ```easy_install pip```
* Change [ansible/hosts](ansible/hosts) file to put your hosts IP
* Install ansible extra modules:
  * RVM: `sudo ansible-galaxy install rvm_io.rvm1-ruby`

## Remote hosts - Managed nodes:

* In each managed node, pointed by [hosts](ansible/hosts), you need to
communicate via **ssh** :
  * Install python 2.4 or later
  * Run open-ssh
  * Enable your user to run commands as sudo without request password
  * Add you ssh public key to your user in remote hosts. [Here's an
  example](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
