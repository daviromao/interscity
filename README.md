# Kong API Gateway

This repository has the basic structure to use InterSCity with 
[Kong](https://getkong.org/) - a scalable, open-source tool to 
implement the
[API Gateway design pattern](http://microservices.io/patterns/apigateway.html).

For this purpose we use a Docker Compose template that provides a Kong
container with a Postgres
database plus an instance of Swagger UI to provide
a dynamic web page for InterSCity API's documentation, which is placed at
*dist/api/* folder.

To setup this template execute:

```shell
$ ./scripts/setup
```

To run this template execute:

```shell
$ ./scripts/development start
```

Kong will be available on the following ports:
* `8000` - HTTP API Gateway
* `8443` - HTTPS API Gateway
* `8001` - Kong Admin API
* `8888` - InterSCity API docs with swagger-ui

To stop running containers of this template execute:

```shell
$ ./scripts/development stop
```

## Using Kong as a Load Balacer

We provide an easy way to offer InterSCity microservices proxied by Kong with
[load balacing](https://getkong.org/docs/0.10.x/loadbalancing/), you only
need to run the following command before starting microservices:

```shell
$ ./scripts/development register
```

This script will create a new Upstream for each microservice and register
their APIs rules for proxing purposes. By default, it assumes you are running
the Kong Admin service in **localhost:8001**. You may use the **KONG\_ADMIN\_HOST**
environment variable to set the correct Kong Admin host address:

```shell
$ KONG_ADMIN_HOST=http://kong:8001 ./scripts/development register
```

Thus, you can run several instances of each microservice. They only will
need to register as a [target](https://getkong.org/docs/0.10.x/admin-api/#target-object)
on the proper upstream. Probrably, each microservice will offer an automated
script to easily register new instances on Kong.

## Using Kong with single microservices instances

You may use Kong to directly proxy requests for a single instance of
each microservice. Each microservice must register its API in Kong and
provide its url as the upstream through [Kong's API](https://getkong.org/docs/0.10.x/getting-started/adding-your-api/).
Alternatively, you may use the [Kong Dashboard](https://github.com/PGBI/kong-dashboard)
which is started through the above mentioned Docker Compose template. It can be
accessed through the address `http://localhost:8080` in a web browser.
Kong Dashboard is a UI panel to facilitate the interaction with Kong
Admin API. When required,
you must inform Kong's url: `http://kong:8001`.


## Registered services

Currently, the following microservices of InterSCity automatically register
themselves:
* Resource Adaptor
* Resource Catalog
* Data Collector
* Actuator Controller
* Resource Discovery

Front-end services should run on subdirectories in order to properly
server their assets and correctly build their links. However, different from
the above mentioned services, we cannot use the `strip\_url` option
while registering them on Kong.

# API Docs

The `/dist` folder contains [Swagger](https://swagger.io/) documentation of
the InterSCity's
REST APIs. This documentation considerers that you are running the InterSCity
with Kong. However, the documentation also divide the endpoints by microservice
and therefore also documents the individual APIs of each microservice.

In the `/dist/api` folder, you'll find the specifications of the api.
Those who need to edit the documentation file  must use the Swagger Online
Editor, import one of the files (swagger.yml or swagger.json), and, after
finish editing, download the new docs in both extensions.

To visualize and interact with the API’s resources, we use the
[Swagger UI](https://swagger.io/swagger-ui/). It automatically generates a 
Web page from the Swagger specification, with the visual documentation.

## Quick Links

* [Swagger](https://swagger.io)
* [Swagger OpenAPI 3.0 Specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md)
* [Online Swagger Editor](http://editor.swagger.io/)
* [Swagger UI](https://swagger.io/swagger-ui/)
* [Kong](https://getkong.org/)
* [Kong Dashboard](https://github.com/PGBI/kong-dashboard)
* [Kong Load Balacing](https://getkong.org/docs/0.10.x/loadbalancing/)

