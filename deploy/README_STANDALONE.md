# Step-by-Step for a standalone Deploying InterSCity

Ansible scripts to deploy InterSCity in a Docker Swarm environment.

# Requirements

# At Local Machine (Check local enviroment)

* 5GB of RAM available
* 25GB of disk
* VirtualBox
* Vagrant

* Local machine depencies (step-by-step)

 - **Python 3.8+** Needed for Ansible
 ```
  $ sudo apt install python3.10
  $ python3.10 --version
  ```
 - **PIP 3**
  ```
  $ sudo apt install python3-pip
  $ pip -V
  ```
 - **Ansible 2.8+** Needed for Ansible
  ```
  $ sudo apt install ansible
  $ ansible --version
  ```
 - **OpenSSH**
  ```
  $ sudo apt install openssh-server
  $ ssh -v Protocol
  ```

  - **Virtualbox**
  ```
  $ sudo apt install virtualbox
  virtualbox --help
  ```
  - **Upgrade Vagrant**

  ```
  $ wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  $ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  $ sudo apt update && sudo apt install vagrant
  $ vagrant --version
  ```
   - **Setup ip range**
  https://www.virtualbox.org/manual/ch06.html#network_hostonly
  
  Since Virtual Box 6.1.24 hosts are limited to the range 192.168.56.0/21 so configure the file of new range.
  For example, to allow 10.0.0.0/8 and 192.168.0.0/16 IPv4 ranges as well as 2001::/64 range put the following lines
into /etc/vbox/networks.conf:
  ```
  $ sudo mkdir /etc/vbox/
  $ sudo touch /etc/vbox/networks.conf 
  $ sudo nano /etc/vbox/networks.conf
  * 10.0.0.0/8 192.168.0.0/16
  * 2001::/64
  $ cat /etc/vbox/networks.conf
  ```
  save the file
  
 **Docker**
  ```
 $ sudo apt install docker-compose
 $ docker --version
  ```
 **Open ports**
  - TCP ports: `2376`, `2377` and `7946`
  - UDP ports: `7946` and `4789`
  ```
  $ sudo ufw allow 2376/tcp
  $ sudo ufw allow 2377/tcp
  $ sudo ufw allow 7946/tcp
  $ sudo ufw allow 7946/udp
  $ sudo ufw allow 4789/udp
  ```
  **Local public key**
  ```
  $ cat ~/.ssh/id_rsa.pub
  ```
  Note the output

  If necessary, create your public keys as:
  ```
  $ ssh-keygen
  id_rsa
  ```
  The private *id_rsa* and public *id_rsa.pub* keys will be generated at (/home/$user/.ssh/)

**Vagrant up (Create hosts)**
  ```
  $ cd interscity-platform/deploy
  $ vagrant up
  ```

# At Host Machine (Check enviroment)

* Virtual machine depencies (step-by-step)

* One host: gateway-machine
* Operating System
  - GNU/Linux Debian Stretch

 - **Acess vagrant machine**
  ```
  $ vagrant ssh gateway-machine
  ```
 - **Save your public key into host machine**
  ```
  $ echo public_key_string >> ~/.ssh/authorized_keys
  ```
  replace *public_key_string* as your outupt from public key executed from a step before at "Note the output"

 - **Verify SSH**
  ```
  $ ssh -v Protocol
  ```
 - **Verify python**
  ```
  $ python --version
  ```
 - **Verify pip**
  ```
  $ pip -V
  ```
 - **exit vagrant machine**
  ```
  $ exit
  ```
# At Local Machine (Deploy to hosts)

 - **Deploy services**
  ```
  $ cd insterscity-platform/deploy/ansible
  $ ansible-playbook setup-swarm.yml -i standalone_vagrant_host
  ```
  If it fails, enter vagrant machine and run:
  ```
  $ sudo apt --fix-broken install
  ```
  and repeat the setup-swarm again

  The setup swarm script is available in the file [/ansible/roles/docker/tasks/main.yml](./ansible/roles/docker/tasks/main.yml)
  ```
  $ ansible-playbook deploy-swarm-stack.yml -i standalone_vagrant_host
  ```
  The setup swarm script is available in the file [/ansible/roles/docker/tasks/main.yml](./ansible/roles/docker/tasks/main.yml)

# At host machine (Check services)

  Enter host machine
  ```
  $ vagrant ssh gateway-machine
  ```
  Verify docker services:
  ```
  $ sudo docker service ls
  ```
  Force service at host machine:
  ```
  $ sudo docker service update --force <docker container id>
  ```
  Check host services:
  ```
  $ curl http://10.10.10.104:8001/upstreams
  ```
  - should return 5 entries (all applications and the kong-api-gateway)
  ```
  $ curl http://10.10.10.104:8001/apis
  ```
  - should return 6 entries (all applications)
  ```
  $ curl http://10.10.10.104:8000/catalog/resources
  $ curl http://10.10.10.104:8000/collector/resources/data
  ```

  # Run test cases
  ```
  $ sudo apt install ruby-full
  $ ruby --version
  ```
  ```
  $ sudo apt install ruby-bundler
  $ bundle --version
  ```
  ```
  $ cd interscity/src/test
  ```
  Update Gemfile to ruby 3.0.2 (or last one installed)
  ```
  $ bundle install
  ```
  type sudo password if asked
  or install one by one with
  ```
  $ sudo gem install faraday rspec
  ```
  faraday and rspec are the gems needed for test
  ```
  $ rspec ./spec/requests_helper.rb
  ```
  ## Documentation ##
  
   interscity-platform documentation: https://gitlab.com/interscity/interscity-platform/docs
