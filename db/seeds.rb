p "Dropping data"
Resource.delete_all
p "Creating data"

Resource.create(name:"trafficlight",uri:"123.123.123.123",uuid:"1")
Resource.create(name:"trafficlight1",uri:"123.123.123.120",uuid:"2")
Resource.create(name:"trafficlight2",uri:"123.123.123.112",uuid:"3")
