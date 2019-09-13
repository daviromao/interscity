# Hacking InterSCity Platform

InterSCity Platform adopts a microservice architecture which imposes more complexity to developers who desire to bring up the services on their own machines.

The objective of this document is to detail setup requirements, steps and later the available development tasks such as linting and automated tests.

For **deployment** instructions, please check the specific [README](deploy/README.md).

## Contact other developers and users

You can ask to join the following mailing list: https://groups.google.com/forum/#!forum/interscity-platform.

## Technology overview

The most important thing you must know is about Ruby on Rails. This is the framework used on all 5 services. The canonical reference online for it is:

* https://guides.rubyonrails.org/

If you want to read a book, look for "Agile Web Development With Rails".

On the infrastructure side there are three main topics:

* [Ansible](https://docs.ansible.com/ansible/latest/index.html)
* [Docker](https://docs.docker.com/)
* [Docker Swarm](https://docs.docker.com/engine/swarm/)

## Requirements

* Ruby
  - Our preferred way of installation is using [RVM](https://rvm.io/)
  - Check the exact version [.ruby-version](src/.ruby-version)
* Services that are expected to be up and running
  - PostgreSQL
  - RabbitMQ
  - MongoDB

## Setup

Given all requirements are met, you must enter the directory of each service under `src`:

* [actuator-controller](src/actuator-controller)
* [data-collector](src/data-collector)
* [resource-adaptor](src/resource-adaptor)
* [resource-cataloguer](src/resource-cataloguer)
* [resource-discoverer](src/resource-discoverer)

On each of them run `./bin/setup`.

## Testing

We perform **static code analysis** using [rubocop](https://github.com/rubocop-hq/rubocop). Depending on how you have installed Ruby, it is already installed. To check, from within the `src` directory run

`which rubocop`

If it is not installed, run `gem install rubocop:0.74.0 rubocop-rails --no-doc`.

To check if your local changes to the core are valid run `rubocop`.

To check for **code correctness** we use [RSpec](https://relishapp.com/rspec/rspec-rails/docs) for automated testing. It is your duty as a developer to cover new code with automated tests and keep the already existent ones passing.

To run tests for each service, from within their source directory run `rails spec`.
