#capacity
#capacity_content

class ResourceAdaptorMock
  
  
  def traffic_light_mock(params)
      status = params[:capability][:request_status]
       response = Hash.new
       if(status == 'green')
          response = {:request_status => 201, :message => "The stus changed succesfully to green and go!"}
       elsif(status=='yellow')
          response = {:request_status => 201, :message => "The stus changed succesfully to yellow and take care!"}
       else
         response = {:request_status => 400, :message => "Tried to chance the status ang got an error.!"}
       end
  end
end

