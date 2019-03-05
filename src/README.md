# InterSCity Development Environment

This repository is composed of the scripts required to run all InterSCity's
microservices on the development environment. 
This project was tested in a GNU Linux Debian 8 and 9
environments.

## Dependencies

* Git
* Ruby 2.3
  * You can install it using [RVM](https://rvm.io)
* [Docker (>= 1.13)](https://www.docker.com/)
* [Docker Compose (>= 1.10)](https://docs.docker.com/compose/)

## Setup

* Clone the repository
* Init submodules:
  `git submodule init`
* Update submodules:
  `git submodule update`
* Setup docker containers:
  `./project setup`

## Run the Development Environment

* Run the script:
  `./project start`

After running the project, microservices will be available through
[Kong](https://getkong.org/), which is an API Gateway tool that routes 
HTTP requests to InterSCity's microservices based on the URL.
Kong will be available on the following ports:
* `8000` - HTTP API Gateway
* `8443` - HTTPS API Gateway
* `8001` - Kong Admin API
* `8080` - Kong Dashboard
* `8888` - InterSCity API documentation

One may use the Kong Dashboard to manage InterSCity's APIs. When required,
you must inform Kong's url: `http://kong:8001`.

The following URLs are used to access the microservices:
* `\adaptor` - Resource Adaptor
* `\catalog` - Resource Catalog
* `\collector` - Data Collector
* `\actuator` - Actuator Controller
* `\discovery` - Resource Discovery


## Stop the Development Environment

* Run containers:
  `./project stop`

> OBS: One should always stop all microservices to avoid name and bind conflicts

## Run tests

* You need to install shunit2 and moreutils package using the command:

    `$ apt-get install moreutils shunit2`

* To run all tests execute the command:

    `./project test`
