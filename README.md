![Build Status](https://gitlab.com/interscity/interscity-platform/resource-discoverer/badges/master/build.svg)
---

## Docker Setup

* Install Docker: (google it)
* Run on terminal:
  * ```$ script/setup```
  * ```$ script/development start``` # start the container
  * ```$ script/development stop```  # stop the container

When the container is running you can access the application on
http://localhost:3003

To execute commands into the started container you can run:

```$ development exec <command>```

## Workaround

Please, try the following approaches to fix possible errors raised when 
trying to start docker services:

### Bind problem

If you have bind errors while trying to start a docker service, try
to remove the docker-network **platform** and create it again. If this not fix
the problem, run the following commands:

* Stop docker deamon: ```sudo service docker stop```
* Remova o arquivo local-kv: ```sudo rm /var/lib/docker/network/files/local-kv.db```
* Start docker deamon: ```sudo service docker start```
* Create the network again: ```sudo docker network create platform```
* Run the container: ```./script/development start```

### Name problem

If get any name conflicts while trying to run a docker container, try to 
follow these steps:

* Stop current container: ```./script/development stop```
* Start the container: ```./script/development start```

# Welcome to Discovery Service API

The *Discovery Service*'s main goal is to provide methods to find resources uuids collected
from *Resources Cataloguer*.

This service is used by applications to provide sensors and actuators uuids (universally unique identifier) from *Resources Cataloguer*
and last data collected from *Data Collector*.

# How to use

We created a [manual](https://social.stoa.usp.br/poo2016/projeto/grupo-5-middleware-cidade-inteligente) to understand our API. In this manual can be found a data structure used to return the data and some usage examples.

---
API Services

## get /discovery/resources/? capability=[capability_name]&lat=[number]&lon=[number]&radius=[number]&min_cap_value=[minValue]&max_cap_value=[maxValue]&cap_value=[value]

Obs: The parameter cap_value is used to filter resources with a specific capability value and should not be used with the min_cap_value/max_cap_value

JSON response example:
```
{
	"resources": [{
		"uuid": 2,
		"lat": 20,
		"lon": 20
	}, {
		"uuid": 3,
		"lat": 30,
		"lon": 30
	}]
}
```
---
Useful links

>* [Project description](https://social.stoa.usp.br/poo2016/projeto/projeto-plataforma-cidades-inteligentes) @ STOA
>* [Discovery Services description](https://social.stoa.usp.br/poo2016/projeto/grupo-5-middleware-cidade-inteligente) @ STOA
>* [Group Repository](https://gitlab.com/interscity/interscity-platform)
>* [Discovery Service Sequence UML Diagram](doc/SequenceDiagram_v1.png)
>* [email list](https://groups.google.com/forum/#!forum/pci-lideres-equipe-de-organizacao-poo-ime-2016)
