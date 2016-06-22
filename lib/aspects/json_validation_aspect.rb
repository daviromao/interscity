require 'aspector'

class JsonValidationAspect < ActionController::Base


  def self.before (controller)
    begin
      debugger
      controller.params.require(:data).permit(:uuid,:capability => [:name,:value])
    rescue Exception => e
      controller.respond_error e, 400
      return false
    end
  end

end