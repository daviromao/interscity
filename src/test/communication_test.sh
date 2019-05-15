. $(dirname $0)/helper/test_helper.sh

test_communication_from_resource_adaptor() {
	ping resource-adaptor data-collector
	assertEquals 0 "$?"
	ping resource-adaptor resource-cataloguer
	assertEquals 0 "$?"
	ping resource-adaptor resource-viewer
	assertEquals 0 "$?"
}

test_communication_from_resource_catologuer() {
	ping resource-adaptor data-collector
	assertEquals 0 "$?"
	ping resource-adaptor resource-adaptor
	assertEquals 0 "$?"
	ping resource-adaptor resource-viewer
	assertEquals 0 "$?"
}

test_communication_from_resource_viewer() {
	ping resource-adaptor data-collector
	assertEquals 0 "$?"
	ping resource-adaptor resource-cataloguer
	assertEquals 0 "$?"
	ping resource-adaptor resource-adaptor
	assertEquals 0 "$?"
}

test_communication_from_data_collector() {
	ping resource-adaptor resource-viewer
	assertEquals 0 "$?"
	ping resource-adaptor resource-cataloguer
	assertEquals 0 "$?"
	ping resource-adaptor resource-adaptor
	assertEquals 0 "$?"
}

test_connection_with_resource_adaptor(){
	verify_connection 3002
	assertEquals 0 "$?"
}

test_connection_with_resource_viewer(){
	verify_connection 4200
	assertEquals 0 "$?"
}

test_connection_with_resource_cataloguer(){
	verify_connection 3000
	assertEquals 0 "$?"
}

test_connection_with_data_collector(){
	verify_connection 4000
	assertEquals 0 "$?"
}

load_shunit2
