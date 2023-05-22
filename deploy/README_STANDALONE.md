# Step-by-Step for a standalone Deploying interSCity

Ansible scripts to deploy interSCity in a Docker Swarm environment.

# Requirements

# STEP 1 - At Local Machine (Check local enviroment)

* Local machine:
  * Linux Debian based
  * 5GB of RAM available
  * 25GB of disk

## Local machine depencies (step-by-step)

Go to interSCity deploy folder:
```shell
$ cd interscity-platform/deploy
```
## * *Option 1*: __Fast-way__ : run the script file: [localScript.sh](./localScript.sh)

```shell
$ chmod +x localScript.sh
$ ./localScript.sh
```
Finishing the Script, **reboot the PC** to finish the setup!

And jump to *Local public key* item.

## * *Option 2*: __Step-by-Step__: or do it manualy wit the follow commands below:

- **Python 3.8+** Needed for Ansible [skip if localScript.sh]
```shell
$ sudo apt install python3.10
$ python3.10 --version
```
- **PIP 3** [skip if localScript.sh]
```shell
$ sudo apt install python3-pip
$ pip -V
```
- **Ansible 2.8+** Needed for Ansible [skip if localScript.sh]
```shell
$ sudo apt install ansible
$ ansible --version
```
- **OpenSSH** [skip if localScript.sh]
```shell
$ sudo apt install openssh-server
$ ssh -v Protocol
```

- **Virtualbox** [skip if localScript.sh]
```shell
$ sudo apt install virtualbox
$ virtualbox --help
```
- **Upgrade Vagrant** [skip if localScript.sh]
```shell
$ wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
$ sudo apt update && sudo apt install vagrant
$ vagrant --version
```
- **Setup ip range** [skip if localScript.sh]

___Troubleshoot___: Since Virtual Box 6.1.24 hosts are limited to the range 192.168.56.0/21 so configure the file of new range.
For example, to allow 10.0.0.0/8 and 192.168.0.0/16 IPv4 ranges as well as 2001::/64 range put the following lines
into /etc/vbox/networks.conf:
```shell
$ sudo mkdir /etc/vbox/
$ sudo touch /etc/vbox/networks.conf 
$ sudo echo "* 10.0.0.0/8 192.168.0.0/16" >> /etc/vbox/networks.conf
$ sudo echo "* 2001::/64" >> /etc/vbox/networks.conf
$ cat /etc/vbox/networks.conf
```
more info: https://www.virtualbox.org/manual/ch06.html#network_hostonly

**Docker** [skip if localScript.sh]
```shell
$ sudo apt install docker-compose
$ docker --version
```
**Open ports** [skip if localScript.sh]
- TCP ports: `2376`, `2377` and `7946`
- UDP ports: `7946` and `4789`
```shell
$ sudo ufw allow 2376/tcp
$ sudo ufw allow 2377/tcp
$ sudo ufw allow 7946/tcp
$ sudo ufw allow 7946/udp
$ sudo ufw allow 4789/udp
```
**Local public key** [printed at the end of localScript.sh]
```shell
$ cat ~/.ssh/id_rsa.pub
```
**SHH Keys**
___Troubleshoot___: If not already available, create a passwordless SSH public keys to your local machine.

Enter the command bellow without typing a password (replace *$USER* to your current user):
```shell
$ ssh-keygen
$ Enter file in which to save the key (/home/$USER/.ssh/id_rsa): 
$ Enter passphrase (empty for no passphrase): 
$ Enter same passphrase again: 
Your identification has been saved in /home/$USER/.ssh/id_rsa
Your public key has been saved in /home/$USER/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:Vfc4OWr2hGJ34ZC/O50s2XjN6LN407O+Lnw5XKPpSc $USER@localmachinename
The key's randomart image is:
+---[RSA 3072]----+
|            oo+++|
|           .o++oo|
|          ..+o+*o|
|         .  *++oo|
|        S  ++++o.|
|            O.+ +|
|             B++ |
|              E +|
|               Bo|
+----[SHA256]-----+
```
$USER will be your local user, and localmachinename your local machine name

Note: Leaving the file empty uses the default value instead: *id_rsa*. (Will overwrite if a file is already available in ./ssh)
```shell
/home/username/.ssh/id_rsa already exists.
$ Overwrite (y/n)?
``` 
The private *id_rsa* and public *id_rsa.pub* keys will be generated at (/home/$USER/.ssh/)

more info: https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server

Finishing it, **reboot the PC** to finish the setup!

**Vagrant up (Create hosts)**

Go to deploy subfolder:
```shell
$ cd interscity-platform/deploy
```

```shell
$ vagrant up
```

Debian9 repositories need to be updated at virtual machine:

```shell
$ vagrant ssh gateway-machine
```

```shell
$ sudo nano /etc/apt/sources.list
```
Update from
```shell
# deb cdrom:[Debian GNU/Linux 9.12.0 _Stretch_ - Official amd64 NETINST 20200209-02:13]/ stretch main

#deb cdrom:[Debian GNU/Linux 9.12.0 _Stretch_ - Official amd64 NETINST 20200209-02:13]/ stretch main

deb http://deb.debian.org/debian stretch main
deb-src http://deb.debian.org/debian stretch main

deb http://security.debian.org/debian-security stretch/updates main
deb-src http://security.debian.org/debian-security stretch/updates main
```
To:
```shell
# deb cdrom:[Debian GNU/Linux 9.12.0 Stretch - Official amd64 NETINST 20200209-02:13]/ stretch main

#deb cdrom:[Debian GNU/Linux 9.12.0 Stretch - Official amd64 NETINST 20200209-02:13]/ stretch main

#deb http://deb.debian.org/debian stretch main
deb http://archive.debian.org/debian stretch main
#deb-src http://deb.debian.org/debian stretch main
deb-src http://archive.debian.org/debian stretch main

#deb http://security.debian.org/debian-security stretch/updates main
deb http://archive.debian.org/debian-security stretch/updates main
#deb-src http://security.debian.org/debian-security stretch/updates main
deb-src http://archive.debian.org/debian-security stretch/updates main
```

The host *gateway-machine* should be created!

___Troubleshoot___: If you are trying to build a VM with the same name, delete/remove it from VirtualBox first and remove the remain files from */home/$USER/.VirutalBox VMS/* and try again!

# STEP 2 - At Host Machine (Check enviroment)

* Virtual machine depencies (step-by-step)
  * One host: gateway-machine
  * Operating System: GNU/Linux Debian Stretch

- **Access vagrant machine**
```shell
$ vagrant ssh gateway-machine
```
- **Save your public key into host machine**
```shell
$ echo public_key_string >> ~/.ssh/authorized_keys
```
Replace *public_key_string* as your outupt from public key executed from a step before at "Note the output" [printed at the end of localScript.sh]

___Troubleshoot___: Maybe some resources couldn't be downloaded and installed due to the lack of a ssh public keys into the host. So, repeat the *Vagrant Up* process from step 1 again if any of the below items are absent from the host machine:

- **Verify SSH**
```shell
$ ssh -v Protocol
```
- **Verify python**
```shell
$ python --version
```
- **Verify pip**
```shell
$ pip -V
```
Install it if not available (sometimes the script does not install it, not sure why cause it`s already in the [main.yml](./ansible/roles/common/tasks/main.yml) file:
```shell
$ sudo apt install python-pip
$ pip -V
```shell

- **exit from host machine**
```shell
$ exit
```

# STEP 3 - At Local Machine (Deploy to hosts)

## - **Setup host (Update apps)**

(You need to setup everytime the virtual machine reboot)

```shell
$ cd insterscity-platform/deploy/ansible/
$ ansible-playbook setup-swarm.yml -i standalone_vagrant_host
```
___Troubleshoot___: If it fails, enter in the vagrant machine and run:
```shell
$ vagrant ssh gateway-machine
$ sudo apt --fix-broken install
$ exit
```
And repeat the *setup-swarm* again.

ansible-playbook [setup-swarm.yml](./ansible/setup-swarm.yml), will run the commands:
1 - Basic Setup: [main.yml](./ansible/setup-swarm.yml)
2 - Common Setup: [main.yml](./ansible/roles/common/tasks/main.yml)
3 - Docker Setup [main.yml](./ansible/roles/docker/tasks/main.yml)
4 - and complete the setup-swarm.yml setup

## - **Deploy services**

The setup swarm script details is available in the file [/ansible/roles/docker/tasks/main.yml](./ansible/roles/docker/tasks/main.yml)

(You need to deploy everytime the virtual machine reboot)
```shell
$ ansible-playbook deploy-swarm-stack.yml -i standalone_vagrant_host
```
The setup swarm script details is available in the file [/ansible/roles/docker/tasks/main.yml](./ansible/roles/docker/tasks/main.yml)

___Troubleshoot___: Those scripts could be not up-to-date and need to be fixed! (Normally updating to a new version solves the problem)

ansible-playbook [deploy-swarm-stack.yml](./ansible/deploy-swarm-stack.yml), will run the commands:
1 - Deply Services: [main.yml](./ansible/roles/deploy-swarm-stack/tasks/main.yml)
2 - and complete the deploy-swarm-stack.yml setup

# STEP 4 - At host machine (Check services)

Enter host machine
```shell
$ vagrant ssh gateway-machine
```
Verify docker status:
```shell
$ docker --version 
$ systemctl status -l docker
```

Verify docker services:
```shell
$ sudo docker service ls
```
Check docker running/stop:
```shell
$ sudo docker ps -a
```
Check docker logs
```shell
$ sudo docker logs <container_id>
```
___Troubleshoot___: Force service update at host machine:
```shell
$ sudo docker service update --force <docker container id or name>
$ sudo docker service update --force interscity-platform_kong-docs
$ sudo docker service update --force interscity-platform_mongodb
$ sudo docker service update --force interscity-platform_datacollector
overall progress: 1 out of 1 tasks 
1/1: running   [==================================================>] 
verify: Service converged 
```
Check host services:
```shell
$ curl http://10.10.10.104:8001/upstreams
```
- should return 5 entries (all applications and the kong-api-gateway)
```shell
$ curl http://10.10.10.104:8001/apis
```
- should return 6 entries (all applications)
```shell
$ curl http://10.10.10.104:8000/catalog/resources
$ curl http://10.10.10.104:8000/collector/resources/data
```

# STEP 5 - Run test cases

Install Ruby [skip if localScript.sh]
```shell
$ sudo apt install ruby-full
$ ruby --version
```
Install bundler [skip if localScript.sh]
```shell
$ sudo apt install ruby-bundler
$ bundle --version
```
```shell
$ cd interscity/src/test/
```
___Troubleshoot___: It was necessary to update the Gemfile to ruby 3.0.2 to make it works! (Maybe you will need to update it in the future to a newer version)
```shell
$ bundle install
```
Note: Enter sudo password if asked only!

Or install one by one with:
```shell
$ sudo gem install faraday rspec
```
faraday and rspec are the gems needed for testing.

After that, check the system health running the follow test cases:
```shell
$ rspec ./spec/requests_helper.rb
$ rspec ./spec/actuator_spec.rb
$ rspec ./spec/catalog_spec.rb
$ rspec ./spec/discovery_spec.rb
$ rspec ./spec/spec_helper.rb
$ rspec ./spec/adaptor_spec.rb
$ rspec ./spec/collector_spec.rb
$ rspec ./spec/resource_not_found_bug_spec.rb    
```

___Troubleshoot___: The last two test cases probably will fail due to the lack of data not yet registered, cause it's a clean installation. See how to register data in next step 6!

# Relaunch Host Machine

To power on the host machine again, access the deploy subfoler, and run vagrant up again:

```shell
$ cd interscity-platform/deploy
$ vagrant up
```

# STEP 6 - Using interSCity with API Requests

interscity-platform API: https://playground.interscity.org/
# Postman

Install desktop postman [skip if localScript.sh]
```shell
$ wget --content-disposition https://dl.pstmn.io/download/latest/linux 
$ tar zxvf postman-linux-x64ls.tar.gz
$ sudo mv Postman /opt
$ sudo ln -s /opt/Postman/Postman /usr/local/bin/postman
$ sudo echo "[Desktop Entry]" >> /usr/share/applications/postman.desktop
$ sudo echo "Type=Application" >> /usr/share/applications/postman.desktop
$ sudo echo "Name=Postman" >> /usr/share/applications/postman.desktop
$ sudo echo "Icon=/opt/Postman/app/resources/app/assets/icon.png" >> /usr/share/applications/postman.desktop
$ sudo echo "Exec="/opt/Postman/Postman"" >> /usr/share/applications/postman.desktop
$ sudo echo "Comment=Postman GUI" >> /usr/share/applications/postman.desktop
$ sudo echo "Categories=Development;Code;" >> /usr/share/applications/postman.desktop
```

Now use Postman (or any other api tool) to use the interSCity platform system

To run postman:
```shell
$ postman
```
Follow the example below to learn how to interact with the InterSCity platform:
# Registering a capability

Let's add a new capabilities:

At Postman, create a HTTP request

Select POST and enter the URL: 
```shell
http://10.10.10.104:8000/catalog/capabilities
```
At header add the KEY: 
```shell
Content-type = application/json
```
At Body select raw, JASON, and enter:
```json
{
"name": "temperature",
"description": "Measure the temperature of the environment",
"capability_type": "sensor"
}
```
After SEND the request you should receive the follow response:
```json
{
"id": 69,
"name": "temperature",
"description": "Measure the temperature of the environment",
"capability_type": "sensor"
}
```

Now check the others examples into interSCity playground: https://playground.interscity.org/ 

# Others - Documentation

* interscity-platform documentation: https://gitlab.com/interscity/interscity-platform/docs

* Architecture: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/architecture/Architecture.md

* API documentation: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/api/API.md

* Microservices documentation: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/microservices/Microservices.md

* Deployment: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/deployment/Deployment.md

* Applications: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/applications/applications.md / https://interscity.org/software/interscity-platform/

   * Smart Parking:
    
     * API: https://interscity.org/software/interscity-platform/

     * Front-End: https://gitlab.com/smart-city-platform/smart_parking_maps

   * Smart Traffic Lights:

     * Repository: https://gitlab.com/smart-city-platform/smart-traffic-lights

   * Outdoor Sports Map
  
     * Repository: https://gitlab.com/smart-city-platform/outdoor-sports-map

* Research & Development opportunities: https://gitlab.com/interscity/interscity-platform/docs/-/blob/master/research/opportunities.md