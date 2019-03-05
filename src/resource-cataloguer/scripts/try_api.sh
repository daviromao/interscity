#!/bin/bash

print_help() {
  cat <<EOF
  Usage: $0 [command] [params]

  commands:
    post capabilities uri
      HTTP POST request
      this creates a new resource
      you MUST pass at least one capability and a uri here (this is a unique value for each resource)
        note that the capability must exist. See db/seed.rb for reference

    put capabilities uuid
      HTTP PUT request
      this updates a resource
      you MUST pass at least one capability and a uuid here
        note that the capability must exist. See db/seed.rb for reference

    put-no-cap
      HTTP PUT request without passing a capability
      this updates a resource
EOF
}

if [ "$1" == post ]; then
  if [ "$#" -ne 3 ]; then
    print_help
    exit 1
  fi
curl -X POST -H "Content-Type: application/json" -d "{\"data\": {\"capabilities\":[\"$2\"], \"lat\":2, \"lon\":2, \"description\":\"desc\", \"status\":\"running\",\"uri\":\"$3\",\"collect_interval\":5}}" http://localhost:3000/resources

elif [ "$1" == put ]; then
  if [ "$#" -ne 3 ]; then
    print_help
    exit 1
  fi
curl -X PUT -H "Content-Type: application/json" -d "{\"data\": {\"capabilities\":[\"$2\"], \"lat\":33, \"lon\":1111, \"description\":\"desc\", \"status\":\"running\",\"uri\":\"localhost:12345\",\"collect_interval\":5}}" http://localhost:3000/resources/$3

elif [ "$1" == put-no-cap ]; then
curl -X PUT -H "Content-Type: application/json" -d "{\"data\": {\"lat\":33, \"lon\":1111, \"description\":\"desc\", \"status\":\"running\",\"uri\":\"localhost:12345\",\"collect_interval\":5}}" http://localhost:3000/resources/ba3391a4-9eb9-42a3-a302-93eefa8fbf97

else 
  print_help
fi

