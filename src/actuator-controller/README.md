![Build Status](https://gitlab.com/interscity/interscity-platform/actuator-controller/badges/master/build.svg)

Actuator-Controller API
=====================

Requirements
------------

* MongoDB
  - export the environment variables `MONGO_HOST` and `MONGO_PORT`
* RabbitMQ

Environment Setup
-----------------

* In the project directory, run:
  * ```$ gem install bundle```
  * ```$ bundle install```
  Run the tests:
  * ```$ rspec```

All tests should pass =)

Docker Setup
------------

* Install Docker: (google it)
* Run on terminal:
  * ```$ script/setup```
  * ```$ script/development start``` # start the container
  * ```$ script/development stop```  # stop the container

When the container is running you can access the application on
http://localhost:3001

To execute commands into the started container you can run:

```$ script/development exec <command>```

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


Provides
--------

## post '/commands'

**Expected put body:**
```
{
  "data": [{
    "uuid": "0a841272-c823-4dd6-9bcf-441a7ab27e4b",
      "capabilities": {
        "traffic_light_status": true
      }
  }, {
    "uuid": "b0d1fd3a-c394-472d-a77c-17a93a17a1fd",
      "capabilities": {
        "traffic_light_status": "blue"
      }
  }]
}
```

**The response will look like:**
```
{
  "success": [{
    "state": true,
      "updated_at": "2016-06-27T19:47:57.456Z",
      "code": 200,
      "uuid": "0a841272-c823-4dd6-9bcf-441a7ab27e4b"
  }],
    "failure": [{
      "uuid": "b0d1fd3a-c394-472d-a77c-17a93a17a1fd",
      "code": 422,
      "message": "Unprocessable Entity"
    }]
}
```

## get '/commands'

**The get response will look like:**
```
{
  "commands": [{
    "_id": {
      "$oid": "59395c1329d4b10379bed679"
    },
      "capability": "name",
      "created_at": "2017-06-08T14:15:47.215Z",
      "platform_resource_id": {
        "$oid": "592f33252d895e0001562ee3"
      },
      "status": "pending",
      "updated_at": "2017-06-08T19:22:17.968Z",
      "uuid": "hashudhu",
      "value": {
        "a": [123, 32],
        "b": 32
      }
  }, {
    "_id": {
      "$oid": "59385f1029d4b1006418d10c"
    },
      "capability": "uma",
      "created_at": "2017-06-07T20:16:16.348Z",
      "platform_resource_id": {
        "$oid": "592f33252d895e0001562ee3"
      },
      "status": "processed",
      "updated_at": "2017-06-07T20:16:16.348Z",
      "uuid": "1234",
      "value": "10"
  }, {
    "_id": {
      "$oid": "59385efd29d4b1006418d10b"
    },
      "capability": "uma",
      "created_at": "2017-06-07T20:15:57.454Z",
      "platform_resource_id": {
        "$oid": "592f33252d895e0001562ee3"
      },
      "status": "processed",
      "updated_at": "2017-06-08T19:22:49.744Z",
      "uuid": "1234",
      "value": "10"
  }]
}
```

It is also possible to filter commands, as well as paginate the results.
The filters includes:
* capability
* uuid
* status => ['processed', 'failed', 'rejected', 'pending']

The following request demonstrates the use of these filters:

## get '/commands?page=1&per_page=30&status=processed

**The get response will look like:**
```
{
  "commands": [{
    "_id": {
      "$oid": "59385f1029d4b1006418d10c"
    },
      "capability": "uma",
      "created_at": "2017-06-07T20:16:16.348Z",
      "platform_resource_id": {
        "$oid": "592f33252d895e0001562ee3"
      },
      "status": "processed",
      "updated_at": "2017-06-07T20:16:16.348Z",
      "uuid": "1234",
      "value": "10"
  }, {
    "_id": {
      "$oid": "59385efd29d4b1006418d10b"
    },
      "capability": "uma",
      "created_at": "2017-06-07T20:15:57.454Z",
      "platform_resource_id": {
        "$oid": "592f33252d895e0001562ee3"
      },
      "status": "processed",
      "updated_at": "2017-06-08T19:22:49.744Z",
      "uuid": "1234",
      "value": "10"
  }]
}
```

Useful links
============

* [Project description](https://social.stoa.usp.br/poo2016/projeto/projeto-plataforma-cidades-inteligentes) @ STOA
* [Group Repository](https://gitlab.com/interscity/interscity-platform)
* [email list](https://groups.google.com/forum/#!forum/pci-lideres-equipe-de-organizacao-poo-ime-2016)
