# About this Repo

This is a repository has the basic docker-compose template to
run all external services required by the InterSCity
platform. It is based on the Git repo of the Docker
[official image](https://docs.docker.com/docker-hub/official_repos/) for
[kong](https://registry.hub.docker.com/_/kong/).

This Docker Compose template provisions a Kong container with a Postgres
database, plus a nginx load-balancer and Consul for
service discovery.
After running the template,
the `nginx-lb` load-balancer will be the entrypoint to Kong.

To run this template execute:

```shell
$ docker-compose up
```

To scale Kong (ie, to three instances) execute:

```shell
$ docker-compose scale kong=3
```

Kong will be available through the `nginx-lb` instance on ports:
* `8000` - HTTP API Gateway
* `8443` - HTTPS API Gateway
* `8001` - Kong Admin API

Each microservice must register itself in Kong as a target for its
upstream API.
Moreover, it also start the
[Kong Dashboard](https://github.com/PGBI/kong-dashboard) which can be
accessed through the address `http://localhost:8080` in a web browser. Kong Dashboard
is a UI panel to facilitate the interaction with Kong Admin API. When required,
you must inform Kong's url: `http://kong:8001`

