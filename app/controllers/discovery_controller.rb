class DiscoveryController < ApplicationController
  def resources
	#render params[].each_with_index {|value, index| puts "[#{index}] == #{value}" }

	render status: 400 if request.GET.size == 0

	if request.GET.size > 0
		render json: {data: request.params}, status: 200
	end

  end
end
