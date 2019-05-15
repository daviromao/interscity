. $(dirname $0)/helper/test_helper.sh

test_from_resource_adaptor() {
	run_unit_tests resource-adaptor
	assertEquals 0 "$?"
}

test_from_resource_catologuer() {
	run_unit_tests resource-cataloguer
	assertEquals 0 "$?"
}

test_from_data_collector() {
	run_unit_tests data-collector
	assertEquals 0 "$?"
}

test_from_actuator_controller() {
	run_unit_tests actuator-controller
	assertEquals 0 "$?"
}

test_from_resource_discoverer() {
	run_unit_tests resource-discoverer
	assertEquals 0 "$?"
}

load_shunit2
