# frozen_string_literal: true

require 'rubygems'
require 'thin'
require 'faye'

Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(mount: '/collector', timeout: 45)
run faye_server
