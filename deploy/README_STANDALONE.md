# Step-by-Step for a standalone Deploying interSCity

Ansible scripts to deploy interSCity in a Docker Swarm environment.

# Requirements

# STEP 1 - At Local Machine (Check local enviroment)

* 5GB of RAM available
* 25GB of disk

## Local machine depencies (step-by-step)

* *Option 1*: __Fast-way__ : run use the script file: [localScript.sh](./localScript.sh)

and jump to *Local public key* item

 ```
  $ chmod +x localScript.sh
  $ ./localScript.sh
```

* *Option 2*: __Step-by-Step__: use the follow commends below:

 - **Python 3.8+** Needed for Ansible [skip if localScript.sh]
 ```
  $ sudo apt install python3.10
  $ python3.10 --version
  ```
 - **PIP 3** [skip if localScript.sh]
  ```
  $ sudo apt install python3-pip
  $ pip -V
  ```
 - **Ansible 2.8+** Needed for Ansible [skip if localScript.sh]
  ```
  $ sudo apt install ansible
  $ ansible --version
  ```
 - **OpenSSH** [skip if localScript.sh]
  ```
  $ sudo apt install openssh-server
  $ ssh -v Protocol
  ```

  - **Virtualbox** [skip if localScript.sh]
  ```
  $ sudo apt install virtualbox
  $ virtualbox --help
  ```
  - **Upgrade Vagrant** [skip if localScript.sh]

  ```
  $ wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  $ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  $ sudo apt update && sudo apt install vagrant
  $ vagrant --version
  ```
   - **Setup ip range** [skip if localScript.sh]
  https://www.virtualbox.org/manual/ch06.html#network_hostonly
  
  Since Virtual Box 6.1.24 hosts are limited to the range 192.168.56.0/21 so configure the file of new range.
  For example, to allow 10.0.0.0/8 and 192.168.0.0/16 IPv4 ranges as well as 2001::/64 range put the following lines
into /etc/vbox/networks.conf:
  ```
  $ sudo mkdir /etc/vbox/
  $ sudo touch /etc/vbox/networks.conf 
  $ sudo echo "* 10.0.0.0/8 192.168.0.0/16" >> /etc/vbox/networks.conf
  $ sudo echo "* 2001::/64" >> /etc/vbox/networks.conf
  $ cat /etc/vbox/networks.conf
  ```
  
 **Docker** [skip if localScript.sh]
  ```
 $ sudo apt install docker-compose
 $ docker --version
  ```
 **Open ports** [skip if localScript.sh]
  - TCP ports: `2376`, `2377` and `7946`
  - UDP ports: `7946` and `4789`
  ```
  $ sudo ufw allow 2376/tcp
  $ sudo ufw allow 2377/tcp
  $ sudo ufw allow 7946/tcp
  $ sudo ufw allow 7946/udp
  $ sudo ufw allow 4789/udp
  ```
  **Local public key** [printed at the end of localScript.sh]
  ```
  $ cat ~/.ssh/id_rsa.pub
  ```
  Note the output

  If necessary, create your public keys as:
  ```
  $ ssh-keygen
  ```
  The private *id_rsa* and public *id_rsa.pub* keys will be generated at (/home/$user/.ssh/)

**Vagrant up (Create hosts)**
  ```
  $ cd interscity-platform/deploy
  $ vagrant up
  ```

# STEP 2 - At Host Machine (Check enviroment)

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
  replace *public_key_string* as your outupt from public key executed from a step before at "Note the output" [printed at the end of localScript.sh]

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
# STEP 3 - At Local Machine (Deploy to hosts)

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

# STEP 4 - At host machine (Check services)

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

  # STEP 5 - Run test cases

  Install Ruby [skip if localScript.sh]
  ```
  $ sudo apt install ruby-full
  $ ruby --version
  ```
  Install bundler [skip if localScript.sh]
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
  $ rspec ./spec/actuator_spec.rb
  $ rspec ./spec/catalog_spec.rb
  $ rspec ./spec/discovery_spec.rb
  $ rspec ./spec/spec_helper.rb
  $ rspec ./spec/adaptor_spec.rb
  $ rspec ./spec/collector_spec.rb
  $ rspec ./spec/resource_not_found_bug_spec.rb    
  ```
  # STEP 6 - Using interSCity with API Requests
  
   interscity-platform API: https://playground.interscity.org/
  # Postman

  Install desktop postman [skip if localScript.sh]
  ```
  $ wget --content-disposition https://dl.pstmn.io/download/latest/linux 
  $ tar zxvf postman-linux-x64ls.tar.gz
  $ sudo mv Postman /opt
  $ sudo ln -s /opt/Postman/Postman /usr/local/bin/postman
  $ echo "[Desktop Entry]" >> /usr/share/applications/postman.desktop
  $ echo "Type=Application" >> /usr/share/applications/postman.desktop
  $ echo "Name=Postman" >> /usr/share/applications/postman.desktop
  $ echo "Icon=/opt/Postman/app/resources/app/assets/icon.png" >> /usr/share/applications/postman.desktop
  $ echo "Exec="/opt/Postman/Postman"" >> /usr/share/applications/postman.desktop
  $ echo "Comment=Postman GUI" >> /usr/share/applications/postman.desktop
  $ echo "Categories=Development;Code;" >> /usr/share/applications/postman.desktop
  ```

  Now use Postman (or any other api tool) to use the interSCity platform system

  Follow an example below:
  # Registering a capability
  
  Let's add a new capabilities:

  At Postman, create a HTTP request
  
  Select POST and enter the URL: 
  ```
  http://10.10.10.104:8000/catalog/capabilities
  ```
  At header add the KEY: 
  ```
  Content-type = application/json
  ```
  At Body select raw, JASON, and enter:
  ```
{
  "name": "temperature",
  "description": "Measure the temperature of the environment",
  "capability_type": "sensor"
}
  ```
After SEND the request you should receive the follow response:
  ```
{
    "id": 69,
    "name": "temperature",
    "description": "Measure the temperature of the environment",
    "capability_type": "sensor"
}
  ```

  # Others - Documentation
  
   interscity-platform documentation: https://gitlab.com/interscity/interscity-platform/docs

   Architecture: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/architecture/Architecture.md

   API documentation: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/api/API.md

   Microservices documentation: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/microservices/Microservices.md

   Deployment: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/deployment/Deployment.md

   Applications: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/applications/applications.md

   Research & Development opportunities: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/research/opportunities.md