![Build Status](https://gitlab.com/smart-city-software-platform/actuator-controller/badges/master/build.svg)

Actuator-Controller API
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

Docker Setup
------------

* Install Docker: (google it)
* Run on terminal:
  * ```$ script/setup```
  * ```$ script/development start``` # start the container
  * ```$ script/development stop```  # stop the container

When the container is running you can access the application on
http://localhost:3001

To execute commands into the started container you can run:

```$ script/development exec <command>```

Provides
--------

## put 'actuator/resources'

**Expected put body:**
```
        {
            "data": [{
                "uuid": "0a841272-c823-4dd6-9bcf-441a7ab27e4b",
                "capabilities": {
                    "traffic_light_status": true
                }
            }, {
                "uuid": "b0d1fd3a-c394-472d-a77c-17a93a17a1fd",
                "capabilities": {
                    "traffic_light_status": "blue"
                }
            }]
        }
```

**The response will look like:**
```
        {
        	"success": [{
        		"state": true,
        		"updated_at": "2016-06-27T19:47:57.456Z",
        		"code": 200,
        		"uuid": "0a841272-c823-4dd6-9bcf-441a7ab27e4b"
        	}],
        	"failure": [{
        		"uuid": "b0d1fd3a-c394-472d-a77c-17a93a17a1fd",
        		"code": 422,
        		"message": "Unprocessable Entity"
        	}]
        }
```

## get 'actuator/resources/:uuid/cap_status/:capability'

**The get response will look like:**
```
       {
           'data' => 'red',
           'updated_at' => @res.created_at.utc.to_s
       }
```


## post 'resources'

**Service post content:**
```
    {
        "uuid": "value"
        "capabilities": {name:}
    }
```

**How this service responds**
    * on successful execution: return code 201
    * on failure: return code 400

## put 'resources/:uuid'

```
    Service post content:
    {
        "uuid": "value"
        "capabilities": {name:}
    }
```

**How this service responds**
    * on successful execution: return code 200
    * on failure: return code 400


Useful links
============

* [Project description](https://social.stoa.usp.br/poo2016/projeto/projeto-plataforma-cidades-inteligentes) @ STOA
* [Group Repository](https://gitlab.com/groups/smart-city-software-platform)
* [email list](https://groups.google.com/forum/#!forum/pci-lideres-equipe-de-organizacao-poo-ime-2016)
