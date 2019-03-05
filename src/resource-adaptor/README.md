![Build Status](https://gitlab.com/interscity/interscity-platform/resource-adaptor/badges/master/build.svg)

# README

The detailed documentation can be found in [the Wiki of this repository](https://gitlab.com/interscity/interscity-platform/resource-adaptor/wikis/home).

## Environment Setup

* Install [PostgreSQL](https://www.postgresql.org/download/)
  * Run on terminal: ```$ sudo -u postgres psql```
  * Run on postgresql command line: ```$ create role resource_adaptor with createdb login password 'resource_adaptor';```
  * `export POSTGRESQL_USER=resource_adaptor`
  * `export POSTGRESQL_PASSWORD=resource_adaptor`
* RabbitMQ
* In the project directory, run:
  * ```$ gem install rails-api```
  * ```$ gem install bundle```
  * ```$ bundle install```
  * ```$ bundle exec rake db:create```
  * ```$ bundle exec rake db:migrate```
* Run the tests:
  * ```$ rspec```

You should see all tests passing =)

## Docker Setup

* Install Docker: (google it)
* Run on terminal:
  * ```$ script/setup```
  * ```$ script/development start``` # start the container
  * ```$ script/development stop```  # stop the container

When the container is running you can access the application on
http://localhost:3002

To execute commands into the started container you can run:

```$ scripts/development exec <command>```

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

## Actuator Webhook

The Actuator Webhook allows you to subscribe to actuation events
on the platform. When one of these events occurs, Resource Adaptor
will send a HTTP POST to the webhook's endpoint, a URL provided
in the subscription.

### Subscription

To receive actuators command from the platform, one must subscribe
informing a set of parameters. See the following example using curl command
line tool:

> curl -H "Content-Type: application/json" -X POST -d '@data.json' http://localhost:3002/subscriptions

where the file data.json has the following content:
```
{
  "subscription": {
    "uuid": "0dbdae10-4156-4433-9291-5d261eb0d8eb",
      "url": "http://myendpoint.com",
      "capabilities": ["semaphore"]
  }
}
```

the response will be:
```
{
  "subscription": {
    "url": "http://myendpoint.com",
    "updated_at": "2017-06-09T17:25:04.121Z",
    "uuid": "0dbdae10-4156-4433-9291-5d261eb0d8eb",
    "active": true,
    "created_at": "2017-06-09T17:25:04.121Z",
    "id": 12,
    "capabilities": [
      "semaphore"
    ]
  }
}
```
### Webhook Callback

Each actuator command will generate webhook notifications for
the correspondent subscriptions through the URL callback. Therefore,
to receive such notifications a client must implement a HTTP server to handle
the following request: **POST http://myendpoint.com**

Check the following example with curl command line tool:

> curl -H "Content-Type: application/json" -X POST -d '@payload.json' http://myendpoint.com

where the file payload.json has the following content:
```
{
  "action": "actuator_command",
  "command": {
    "uuid": "0dbdae10-4156-4433-9291-5d261eb0d8eb",
    "url": "http://myendpoint.com",
    "capability": "semaphore",
    "created_at": "2017-06-07T20:16:16.348Z",
    "value": "red"
  }
}
```

Note that if your server returns a success status code, such as 200 or 201,
we will update the command status to **processed**. Otherwise, we will 
set the status to **rejected**.


## Configuration

### Database

We use a relational database to store some important information about all components encapsulated by a resource.

By default, our [database config file](config/database.yml) use the adpater for postgresql.

