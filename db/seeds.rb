p "Dropping data"
Resource.delete_all
p "Creating data"

res = Resource.create(name: "trafficlight", uri: "traffic_light_url", uuid: "1")
cap = res.capabilities.create(name:"change_trafficlight")
