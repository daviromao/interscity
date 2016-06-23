![Build Status](https://gitlab.com/smart-city-platform/actuators-control/badges/master/build.svg)

Actuators-Control API
=====================

Environment Setup
-----------------

* Install RVM
* Run on terminal: ```$ rvm install 2.3.1```
* In the project directory, run:
  * ```$ gem install bundle```
  * ```$ bundle install```
  Run the tests:
  * ```$ rspec```

All tests should pass =)

Provides
--------

* put 'actuator/resources/:uuid/exec/:capability'

Expected put body:

{
   "capability": {value:'green'}
}

* get 'actuator/resources/:uuid/cap_status/:capability''

Data catalog interaction
* post 'resources'

    Service post content:
    {
        "uuid": "value"
        "capabilities": {name:}
    }

    How this service responds
        on successful execution
            return code 201
        on failure
            return code 400

* put 'resources/:uuid'

    Service post content:
    {
        "uuid": "value"
        "capabilities": {name:}
    }
    How this service responds
        on successful execution
            return code 200
        on failure
            return code 400

Needs
-----

* resource_adaptor 		put /resources-adaptor/execute/:capability

Useful links
============

* [Project description](https://social.stoa.usp.br/poo2016/projeto/projeto-plataforma-cidades-inteligentes) @ STOA
* [Actuators-control description](https://social.stoa.usp.br/poo2016/projeto/grupo-5-middleware-cidade-inteligente) @ STOA
* [Group Repository](https://gitlab.com/groups/smart-city-platform)
* [email list](https://groups.google.com/forum/#!forum/pci-lideres-equipe-de-organizacao-poo-ime-2016)
