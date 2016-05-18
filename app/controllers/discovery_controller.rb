require 'rest-client'

class DiscoveryController < ApplicationController
  def resources
	#render params[].each_with_index {|value, index| puts "[#{index}] == #{value}" }

	if request.GET.size == 0
		render status: 400
	else
		#json: {data: request.params}, status: 200

		#test if the param is capability

		unless  params["capability"].blank? 
			params_request = Hash.new
			params_request["capability"] =  params["capability"]

			unless (not params["lat"].blank? and params["lon"].blank?) or
                               (params["lat"].blank? and not params["lon"].blank?)
				params_request["lat"] =  params["lat"]
				params_request["lon"] =  params["lon"]
			else
				render status: 400
				return true
			end

			#uncoment this line when resource catalog is availible
			#catalog_data_return = RestClient.get SERVICES_CONFIG["services"]["catalog"]+'/resources/search', {:params => params_request}
			
			catalog_data_return = catalog_mockup

			render json: catalog_data_return
	
		else
			render status: 400
		
		end

		#return to client a set of ids as json
	end

	def catalog_mockup
		hash_uuids = {:uuids => ["1111","2222","3333","4444"]}
		hash_uuids.to_json
	end

  end
end
