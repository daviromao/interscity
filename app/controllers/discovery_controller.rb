require 'rest-client'

class DiscoveryController < ApplicationController
  def resources
	#render params[].each_with_index {|value, index| puts "[#{index}] == #{value}" }

	if request.GET.size == 0
		render :status => 400
	else
		#json: {data: request.params}, status: 200

		#test if the param is capability
		unless  params["capability"].blank? 
			params_request = Hash.new
			params_request["capability"] =  params["capability"]

			if (not params["lat"].blank? and params["lon"].blank?) or
                               (params["lat"].blank? and not params["lon"].blank?)
				render :plain => "Params are not right.", :status => 400
				return true	
			end
			
			data = JSON.parse(call_to_data_catalog())
						
			if !params["lat"].blank?
				data = call_to_data_collector(data["uuids"], params["lat"], params["lon"])
			end
			render json: data
		else
			render :plain => "Params are not right.", :status => 400
		end

		#return to client a set of ids as json
	end

  end
  private

  def call_to_data_catalog()
	#uncoment this line when resource catalog is availible
	#JSON.parse (RestClient.get SERVICES_CONFIG["services_data_catalog"])

	data_catalog_mockup()
  end

  def call_to_data_collector(uuids, lat, lon)
	#uncoment this line when data collector is availible
	#JSON.parse (RestClient.get SERVICES_CONFIG["services_data_collector"])
	data_collector_mockup(uuids, lat, lon)
  end

  def data_collector_mockup(uuids, lat, lon)
	data = Hash.new
	
	uuids.each { |uuid|	    
	    temp = Hash.new
	    temp = {:lat => lat, :lon => lon}
	    data[uuid] = temp
	}
	data
  end

  def data_catalog_mockup
	hash_uuids = {:uuids => ["1111","2222"]}
	hash_uuids.to_json
  end	
end
