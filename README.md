![Build Status](https://gitlab.com/smart-city-platform/discovery-service/badges/master/build.svg)
---

# Welcome to Discovery Service API

> The *Discovery Service*'s main goal is to provide methods to find resources uuids collected
from *Resources Catalog*.
>
> This service is used by applications to provide sensors and actuators uuids (universally unique identifier) from *Resources Catalog*
and and last data collected from *Data Collector*.

# How to use

> You can find a [step-by-step](https://gitlab.com/smart-city-platform/discovery-service/wikis/basic_setup) to configure the application.
After configuring the application, it should be possible to request and filter data by some parameters.
>
> It was made a [manual](https://social.stoa.usp.br/poo2016/projeto/grupo-5-middleware-cidade-inteligente) to understand our API. In this manual can be found a data structure used to return the data and some usage examples.

---
API Services

>* get /discovery/resources/? capability=[capability_name]&lat=[number]&lon=[number]&radius=[number]&min_cap_value=[minValue]&max_cap_value=[maxValue]&cap_value=[value]
>
>    obs: The parameter cap_value is used to filter resources with a specific capability value and should not be used with the min_cap_value/max_cap_value
>    
>    JSON response example  {"resources": [{"uuid": 2,"lat": 20,"lon": 20}, 
> 	                                      {"uuid": 3,"lat": 30,"lon": 30}]
>                           }

API Dependecies

>* data_catalog 		GET /resources/search? capability=[capability_name]&lat=[number]&lon=[number]&radius=[number]
>* data_collector	GET /resources/data/last?resource_id=:value&min_cap_value=[minValue]&max_cap_value=[maxValue]&cap_value=[value]
> 
>    obs: The parameter cap_value is used to filter resources with a specific capability value and should not be used with the min_cap_value/max_cap_value
>
>    JSON response example {  "resources" : [{ "uuid" : "7", "capabilities":
>                                { "temp" : [{ "value" : "28.31", "date" : "2016-06-21T23:27:35.000Z" }] } }] }

---
Useful links

>* [Project description](https://social.stoa.usp.br/poo2016/projeto/projeto-plataforma-cidades-inteligentes) @ STOA
>* [Discovery Services description](https://social.stoa.usp.br/poo2016/projeto/grupo-5-middleware-cidade-inteligente) @ STOA
>* [Group Repository](https://gitlab.com/groups/smart-city-platform)
>* [Discovery Service Sequence UML Diagram](doc/SequenceDiagram_v1.png)
>* [email list](https://groups.google.com/forum/#!forum/pci-lideres-equipe-de-organizacao-poo-ime-2016)
