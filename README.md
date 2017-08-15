# Kong API Gateway

This repository has the basic structure to use InterSCity with 
[Kong](https://getkong.org/) - a scalable, open-source tool to 
implement the
[API Gateway design pattern](http://microservices.io/patterns/apigateway.html).

For this purpose, we use a Docker Compose template that provides a Kong
container with a Postgres
database plus an instance of Swagger UI to provide
a dynamic web page for InterSCity API's documentation, which is placed at
*api* folder.

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

To stop running containers of this template execute:

```shell
$ ./scripts/development stop
```


Each microservice must register itself in Kong as a target for its
upstream API through [Kong's API](https://getkong.org/docs/0.10.x/getting-started/adding-your-api/).
Alternatively, you may use the [Kong Dashboard](https://github.com/PGBI/kong-dashboard)
which is started through the above mentioned Docker Compose template. It can be
accessed through the address `http://localhost:8080` in a web browser.
Kong Dashboard is a UI panel to facilitate the interaction with Kong
Admin API. When required,
you must inform Kong's url: `http://kong:8001`

