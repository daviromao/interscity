# Requests with CURL

## Actuating

* Sending several commands
> curl -H "Content-Type: application/json" -X POST -d '{"data": [{"uuid": "0a841272-c823-4dd6-9bcf-441a7ab27e4b","capabilities":{"traffic_light_status": true}},{"uuid": "b0d1fd3a-c394-472d-a77c-17a93a17a1fd","capabilities": {"traffic_light_status": "blue"}}]}' ttp://localhost:5000/commands | json_pp

## Get commands status
> curl http://localhost:5000/commands?page=1&per_page=50&uuid=:uuid&capability=semaphore&status=processed | json_pp

