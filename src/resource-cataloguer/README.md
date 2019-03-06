# Resource Cataloguer

![Build Status](https://gitlab.com/smart-city-software-platform/resource-cataloguer/badges/master/build.svg)

Resource Cataloguer is a microservice of the
[InterSCity platform](http://interscity.org/). It is designed to store 
static and meta data of all city resources.

Resource Cataloguer API enables the creation and update of city resources
on the InterSCity platform, storing some static data such as description 
and their capabilities. It also offers endpoints to manage the
available capabilities used on the platform. So, if you want to register a
new resource that has a capability which does not currently exist on the 
platform, you should first register this new capability and then
register the city resource.

# How to use

You must see:
* Setup the Environment
  * [Using Docker](#docker-setup) (recommended).
  * [Using RVM](#rvm-setup).
* [Request examples](requests.md) to understand the Resource Cataloguer
API. 
In this manual you will find a set of requests and responses examples with *curl*,
and the required data structures.

## RVM Setup

By using this option, you will have additional overhead to properly configure
the

* In the project directory, run:
  * ```$ gem install bundle```
  * ```$ bundle install```
* RabbitMQ
* PostgreSQL
  * Install and start it
  * ```$ bundle exec rake db:create```
  * ```$ bundle exec rake db:migrate```
* Run the tests:
  * ```$ bundle exec rspec```

You should see all tests passing =)

## Docker Setup

* Install Docker: (google it)
* Run on terminal:
  * ```$ script/setup```
  * ```$ script/development start``` # start the container
  * ```$ script/development stop```  # stop the container

When the container is running you can access the application on
http://localhost:3000

* To execute commands into the started container you can run:

```$ scripts/development exec resource-cataloguer <command>```

* Run the tests with:

```$ scripts/development exec resource-cataloguer rspec```

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
