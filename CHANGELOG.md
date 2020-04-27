# Revision history for InterSCity Platform

A microservice-based, open-source smart city platform that aims at supporting collaborative, novel smart city research, development, and deployment initiatives.

The version numbers below try to follow the conventions at http://semver.org/.

## Unreleased

* Handle intermitent CI deployment failures
* Improve resource data creation documentation
* Upgrade to Ruby 2.7.1
* Fix wrong deployment verification value
* Create integration tests
* Segment services unit and integration tests
* Persist MongoDB data

## v0.2.0 - 22/10/2019

* Target new revoada servers for deployment
* Upgrade to Ruby 2.6.5
* Improve resource-cataloguer resource update error message
* Fix revoada's deployment inventory
* Setup static code analysis
* Remove legacy development files
* Create HACKING file
* Remove unused resource-discoverer configuration
* Remove unused test framework
* Extract Kong wrapper to service-base gem
* Improve deployment instructions
* Set Ruby and bundler versions on docker images
* Update rails gem
* Add bootsnap dependency to service-base
* Update resource-cataloguer mock_redis gem
* Update resource-adaptor redis-namespace gem
* Update resource-adaptor sidekiq gem
* Update bunny gem
* Update rack-cors gem
* Update puma gem
* Update pg gem
* Update sqlite3 gem
* Create base docker image
* Create service-base gem

## v0.1.0 - 15/08/2019

* Establish a release routine
* Enable continuous delivery
* Remove legacy deployment scripts and update deployment README
* Support standalone applications
* Deploy actuator controller to Swarm
* Deploy resource discoverer to Swarm
* Deploy data collector to Swarm
* Deploy MongoDB to Swarm
* Deploy resource-adaptor to swarm
* Deploy resource-adaptor sidekiq to swarm
* Deploy kong-api-gateway to Swarm
* Deploy resource-cataloguer to Swarm
* Create Dockerfile for kong-api-gateway and push it to the registry as part of CI
* Deploy Kong to Swarm
* Deploy Redis to Swarm
* Deploy RabbitMQ to Swarm
* Improve Ansible tasks for infrastructure installation
* Create Swarm deployment instructions
* Deploy PostgreSQL to Swarm
* Setup Docker Swarm cluster
* Target Ansible scripts to Debian Stretch
* Make docker image generation part of the CI
* There is a lot of work done before 13/05/2019 that is not documented here
