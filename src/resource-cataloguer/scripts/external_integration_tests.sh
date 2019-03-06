#!/bin/bash

# This is a shunit2 test suite

oneTimeSetUp() {
  echo stub
}

setUp() {
  echo 'reseting database'
  rake db:reset
}

testStub() {
  assertEquals 1 1
  assertTrue 0
}

tearDown() {
  echo stub
}

oneTimeTearDown() {
  echo stub
}

. /usr/share/shunit2/shunit2
