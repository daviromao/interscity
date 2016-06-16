#capacity
#capacity_content

class ResourceAdaptorMock
  
  
  def traffic_light_mock(params)
      status = params[:capability][:status]
       response = Hash.new
       if(status == 'green')
          response = {:status => 201, :message => "The stus changed succesfully to green and go!"}  
       elsif(status=='yellow')
          response = {:status => 201, :message => "The stus changed succesfully to yellow and take care!"}
       else
         response = {:status => 400, :message => "Tried to chance the status ang got an error.!"}
       end
  end
end

