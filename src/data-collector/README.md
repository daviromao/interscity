# Data Collector - InterSCity

![Build Status](https://gitlab.com/interscity/interscity-platform/data-collector/badges/master/build.svg)
[![Mezuro](https://img.shields.io/badge/mezuro-green-green.svg)](http://mezuro.org/en/repositories/73)
[![Mezuro](https://img.shields.io/badge/freenode-%40data__collector-blue.svg)]()

---

Data Collector is a microservice of the
[InterSCity platform](http://interscity.org/). Its main goal is to provide
methods to search data collected from city resources.

This microservice offers to developers the access to information coming from
different sensors scattered throughout the city. For example, with this
service one could obtain data of all temperature sensors on a city,
either historical or the most recent data.

# Development requirements

* MongoDB
  - export the environment variables: `MONGO_HOST`; `MONGO_PORT`; `MONGO_CACHE_HOST`; and `MONGO_CACHE_PORT`
* RabbitMQ

# How to use

You must see:
* [How to setup](#docker-setup) the environment with Docker.
* [Request examples](requests.md) to understand the Data Collector API. 
In this manual you will find a set of requests and responses examples with *curl*,
and the required data structures.

## Docker setup

* Install Docker and docker-compose (versão 1.6+): (google it)
* Run on terminal:
  * `$ scripts/setup`
  * `$ scripts/development start` # start the container
  * `$ scripts/development stop`  # stop the container
  * `$ scripts/development exec data-collector <command>` # run a command into data-collector container
  * **(OPTIONAL):** `$ scripts/development exec data-collector rake db:seed`

Now you can access the application on http://localhost:4000

### Workaround

Please, try the following approaches to fix possible errors raised when 
trying to start docker services:

#### Bind problem

If you have bind errors while trying to start a docker service, try
to remove the docker-network **platform** and create it again. If this not fix
the problem, run the following commands:

* Stop docker deamon: ```sudo service docker stop```
* Remova o arquivo local-kv: ```sudo rm /var/lib/docker/network/files/local-kv.db```
* Start docker deamon: ```sudo service docker start```
* Create the network again: ```sudo docker network create platform```
* Run the container: ```./script/development start```

#### Name problem

If get any name conflicts while trying to run a docker container, try to 
follow these steps:

* Stop current container: ```./script/development stop```
* Start the container: ```./script/development start```
