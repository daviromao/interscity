class ActuatorException < Exception

  attr_accessor :request_status

  def initialize (code)
    @request_status = code
  end
end