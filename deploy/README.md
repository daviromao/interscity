# Deploying InterSCity

Ansible scripts to deploy InterSCity in a Docker Swarm environment.

# Requirements

* At least one host, but two or more are recommended
* Operating System
  - GNU/Linux Debian Stretch
* Host requirements
  - **SSH** access
  - Add you ssh public key to your user in remote hosts. [Here's an example](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
  - passwordless sudo permission
  - **Python** must be installed
* The machine which will perform the deployment must have Ansible 2.8 or greater installed
* Make sure to open the required ports for Docker Swarm to work. You can learn how to configure the firewall [here](https://www.digitalocean.com/community/tutorials/how-to-configure-the-linux-firewall-for-docker-swarm-on-ubuntu-16-04). The ports are:
  - TCP ports: `2376`, `2377` and `7946`
  - UDP ports: `7946` and `4789`

## Configuration

1. Create your `hosts` file
  * You can check an example (here)[ansible/vagrant_hosts]
    - It is important to note that if you use `localhost` or `127.0.0.1` you may find issues getting all the services up. Instead use other valid IP addresses on your network.
  * Each host must have a unique `swarm_node_name` variable defined
  * You'll use this variable to set the node label under `swarm_labels` variable defined for the `swarm-manager` group
  * Valid labels are
    - `gateway` (at least one host must have this label as `true`)
    - `data` (at least one host must have this label `true`)
    - `common`
  * It is important that at least one host is in each of the following groups: `swarm-manager`; and `swarm-data-workers`
  * The remaining hosts must be members of the `swarm-workers` group
2. Install Docker Swarm
  * Within the ansible directory run: `ansible-playbook setup-swarm.yml`
    - this step performs, among other tasks, a full system upgrade. If you find an error while running it, please try to reboot the hosts and running it again
    - if this step hangs on the task `docker_swarm` for a while, stop it and run it again

For standalone installations, a host must have both `gateway` and `data` labelled `true`.

## Deployment

Within the ansible directory run: `ansible-playbook deploy-swarm-stack.yml`

This will bring up all services. It may take some time on the first run. You can track the progress further by accessing the manager host and running `docker service ls`.

## Example to check for a correct deployment

Make sure you have assess to your gateway host through ports `8000` and `8001`. Then you can replace `localhost` by your gateway host address and perform the following checks:

* `curl http://localhost:8001/upstreams`
  - should return 5 entries (all applications and the kong-api-gateway)
* `curl http://localhost:8001/apis`
  - should return 6 entries (all applications)
* `curl http://localhost:8000/catalog/resources`
* `curl http://localhost:8000/collector/resources/data`

You can also run the [integration tests](src/test/README.md) to verify everything works as expected.

## Removing services

The `kong-docs` is supposed to be a one-shot service. If you want to remove it after it successfully runs, you can log in the swarm manager and run: `sudo docker service remove interscity-platform_kong-docs`

## Troubleshooting

* **Force service deployment**
  - if a given service is taking too long to retry, on the swarm manager host you can force it with the following
  - `docker service update --force <SERVICE IDENTIFIER>`

# Development

The following instructions are relevant for developers and maintainer of the deployment scripts here. If you are interested only on running an instance of the platform follow the steps at the beginning of this file.

## Additional requirements

* 5GB of RAM available
* 25GB of disk
* Vagrant
  * VirtualBox

## Deploying locally

There's a valid `hosts` file for deploying with Vagrant and VirtualBox. The `vagrant_hosts` defines 5 hosts. The `standalone_vagrant_host` define a single host for standalone installation. For the standalone installation you do not need the 5 machines defined in the Vagrantfile. Therefore, increase the memory to `2048` and leave just the `gateway-machine` definition. Enter in the `ansible` directory and run:

* `vagrant up`
* `ansible-playbook setup-swarm.yml -i <vagrant_hosts | standalone_vagrant_host>`
* `ansible-playbook deploy-swarm-stack -i <vagrant_hosts | standalone_vagrant_host>`
