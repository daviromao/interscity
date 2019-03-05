# Requests with CURL

* Create resource:
> curl -H "Content-Type: application/json" -X POST -d '{"data":{"uri":"example2.com","lat":-23.559616,"lon":-46.731386,"status":"stopped","collect_interval":5,"description":"A simple resource in São Paulo","capabilities":["temperature"]}}' http://localhost:3000/resources | json_pp

* Get all capabilities
> curl http://localhost:3000/capabilities | json_pp
> curl http://localhost:3000/capabilities?capability_type="sensor" | json_pp

* Create capability
> curl -H "Content-Type: application/json" -X POST -d '{"name":"temperature", "description":"Float value in celcius", "capability_type":"sensor"}' http://localhost:3000/capabilities | json_pp
> curl -H "Content-Type: application/json" -X POST -d '{"name":"air_conditioning", "description":"Available status are ['on', 'off']", "capability_type":"actuator"}' http://localhost:3000/capabilities | json_pp

* Update capability
> curl -H "Content-Type: application/json" -X PUT -d '{"description":"Another description]", "capability_type":"sensor"}' http://localhost:3000/capabilities/temperature | json_pp

* Delete Capability
> curl -X DELETE http://localhost:3000/capabilities/temperature
