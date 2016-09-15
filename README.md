![Build Status](https://gitlab.com/smart-city-software-platform/actuators-control/badges/master/build.svg)

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

Docker Setup
------------

* Install Docker: (google it)
* Run on terminal: 
    * ```$ docker pull debian:unstable```
	* ```$ docker build -t smart-cities/actuator-controller . ```
	* ```$ docker run -d -v <path_to_your_source_code>:/actuator-controller/ -p 3001:3000 smart-cities/actuator-controller```

Docker flags:

* -d : run the container as a daemon
* -v : mount a volume from your host to container (share your source code with container)
* -p : map the exposed port to your host (<host_port>:<container_port>)

Now you can access the application on http://localhost:3001


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
