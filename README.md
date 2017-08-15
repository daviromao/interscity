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

## Using Kong

Each microservice must register itself in Kong as a target for its
upstream API through [Kong's API](https://getkong.org/docs/0.10.x/getting-started/adding-your-api/).
Alternatively, you may use the [Kong Dashboard](https://github.com/PGBI/kong-dashboard)
which is started through the above mentioned Docker Compose template. It can be
accessed through the address `http://localhost:8080` in a web browser.
Kong Dashboard is a UI panel to facilitate the interaction with Kong
Admin API. When required,
you must inform Kong's url: `http://kong:8001`.

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

This folder contains the [Swagger](https://swagger.io/) documentation of the InterSCity's
REST APIs. This documentation considerers that you are running the InterSCity
with Kong. However, the documentation also divide the endpoints by microservice
and therefore also documents the individual APIs of each microservice.

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

