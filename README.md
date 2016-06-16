![Build Status](https://gitlab.com/smart-city-platform/discovery-service/badges/master/build.svg)

Discovery Service API
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

You should see all tests passing =)

Provides
--------
* get /discovery/resources/? capability=[capability_name]&lat=[number]&lon=[number]&min_cap_value=[minValue]&max_cap_value=[maxValue]&cap_value=[value]&start_date=[date]&end_date=[date]

    obs: The parameter cap_value is used to filter resources with a specific capability value and should not be used with the min_cap_value/max_cap_value

Needs
-----

* data_catalog 		GET /resources/search

* data_collector	GET /events/?resource_id=:value&limit=:value&start=:value
envia
{data:{
    uudis:{
        cababilities
}}}
responde
{data:
    {uuid:{
}

Useful links
============

* [Project description](https://social.stoa.usp.br/poo2016/projeto/projeto-plataforma-cidades-inteligentes) @ STOA
* [Discovery Services description](https://social.stoa.usp.br/poo2016/projeto/grupo-5-middleware-cidade-inteligente) @ STOA
* [Group Repository](https://gitlab.com/groups/smart-city-platform)
* [email list](https://groups.google.com/forum/#!forum/pci-lideres-equipe-de-organizacao-poo-ime-2016)
