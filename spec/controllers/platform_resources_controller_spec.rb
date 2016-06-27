require 'rails_helper'
require 'securerandom'

RSpec.describe PlatformResourcesController, type: :controller do

  subject {response}

  # Create objects from factories
  let(:empty_capability) { FactoryGirl.build(:empty_capability) }

  let(:missing_args_params) { FactoryGirl.attributes_for(:missing_args) }

  let(:typo_params) { FactoryGirl.attributes_for(:typo) }

  let(:essential_args_params) { FactoryGirl.attributes_for(:essential_args) }

  let (:empty_capability_params) {
    FactoryGirl.attributes_for(:empty_capability)
  }

  let (:with_capability_params) {
    FactoryGirl.attributes_for(:with_capability)
  }

  let (:with_few_capability_params) {
    FactoryGirl.attributes_for(:with_capability_second)
  }

  let (:with_similar_capability_params) {
    FactoryGirl.attributes_for (:with_similar_capability)
  }

  let (:with_more_capability_params) {
    FactoryGirl.attributes_for (:with_more_capability)
  }


  it 'Has a valid factory' do
    expect(empty_capability).to be_valid
  end

  context 'Verify create method by POST using data with no capabilities' do

    it 'Verify request made successfully' do
      post :create, params: { data: essential_args_params }
      expect(response.status).to eq(201)
    end

    it 'Verify if request was stored successfully' do
      expect{ post :create, params: { data: essential_args_params } }
            .to change(PlatformResource, :count).by(1)
    end

    it 'Typo in parameter to post results in a server error' do
      post :create, params: { data: typo_params }
      expect(response.status).to eq(500)
    end

    it 'Wrong number of arguments results in a server error' do
      post :create, params: { data: missing_args_params }
      expect(response.status).to eq(500)
    end

  end

  context 'Verify create method by POST using data with capabilities' do
    it 'POST new platform resource with empty capabilities' do
      post :create, params: { data: empty_capability_params }
      expect(response.status).to eq(201)
    end

    it 'Verify if POST correctly stored data with empty capabilities' do
      expect{ post :create, params: { data: empty_capability_params } }
            .to change(PlatformResource, :count).by(1)
      expect(Capability.count)
            .to eq(empty_capability_params[:capabilities].size)
    end

    it 'POST new platform resource with one capability' do
      params = FactoryGirl.attributes_for(:with_capability,
                                          capabilities: ["weight"])

      post :create, params: { data: params }
      expect(response.status).to eq(201)
    end

    it 'Verify if POST correctly stored data with one capability' do
      params = FactoryGirl.attributes_for(:with_capability,
                                          capabilities: ['weight'])

      expect{ post :create, params: { data: params } }
            .to change(PlatformResource, :count).by(1)
      expect(Capability.count).to eq(params[:capabilities].size)
    end

    it 'POST new platform resource with multiple capabilities' do
      post :create, params: { data: with_capability_params }
      expect(response.status).to eq(201)
    end

    it 'Verify if POST correctly stored data with multiple capabilities' do
      expect{ post :create, params: { data: with_capability_params } }
            .to change(PlatformResource, :count).by(1)
      expect(Capability.count)
            .to eq(with_capability_params[:capabilities].size)
    end

    it 'POST data with a mix of already created capabilities and new one' do
      first_cap = ['a', 'b', 'c']
      second_cap = ['a', 'b', 'x', 'y']

      first_params = FactoryGirl.attributes_for(:with_capability,
                                                capabilities: first_cap,
                                                uuid: SecureRandom.uuid)
      second_params = FactoryGirl.attributes_for(:with_capability,
                                                 capabilities: second_cap,
                                                 uuid: SecureRandom.uuid)
      post :create, params: { data: first_params }
      expect(response.status).to eq(201)
      post :create, params: { data: second_params }
      expect(response.status).to eq(201)

      expect(Capability.count).to eq((first_cap + second_cap).uniq.size)
    end

    it 'Accepts POST data with all capabilities already created' do
      first_cap = ['a', 'b']
      second_cap = ['a', 'b']

      first_params = FactoryGirl.attributes_for(:with_capability,
                                                capabilities: first_cap,
                                                 uuid: SecureRandom.uuid)
      second_params = FactoryGirl.attributes_for(:with_capability,
                                                 capabilities: second_cap,
                                                 uuid: SecureRandom.uuid)

      post :create, params: { data: first_params }
      expect(response.status).to eq(201)
      post :create, params: { data: second_params }
      expect(response.status).to eq(201)

      # Must match with size of both arrays
      expect(Capability.count).to eq(first_cap.size)
      expect(Capability.count).to eq(second_cap.size)
    end

    it 'Rejects POST data with duplicated uuid' do
      first_params = FactoryGirl.attributes_for(:with_capability)
      second_params = FactoryGirl.attributes_for(:with_capability)

      post :create, params: { data: first_params }
      expect(response.status).to eq(201)
      post :create, params: { data: second_params }
      expect(response.status).to eq(400)

    end

    it 'Verify relation between capability and platform resource' do
      post :create, params: { data: with_capability_params }
      expect(response.status).to eq(201)

      # For each capability in the sent data...
      with_capability_params[:capabilities].each do |name|
        # Get the capability id
        cap_id = Capability.find_by_name(name).id

        # Use the model that relates Capability and Platform Resource to find
        # out the corresponding platform resource id
        resourceCapability =
                      PlatformResourceCapability.find_by_capability_id(cap_id)
        resource_id = resourceCapability.platform_resource_id

        # Check if the uuid in the Platform Resource model is correct by
        # comparing it to the sent data's uuid
        resource = PlatformResource.find_by_id(resource_id)
        expect(resource.uuid).to eq(with_capability_params[:uuid])
      end
    end
  # End of post context
  end

  context 'Verify update method by PUT using data with no capabilities' do
    RSpec.shared_examples 'params put' do |key, new_value, description|
      it ": #{description}" do
        new_hash = FactoryGirl.attributes_for (:essential_args)
        new_hash[key] = new_value
        put :update, params: { uuid: new_hash[:uuid], data: new_hash }
        expect(response.status).to eq(201)
        platform = PlatformResource.last
        expect(eval("platform.#{key.to_s}")).to eq(new_hash[key])
      end
    end

    before :each do
      @platform_hash = essential_args_params
      PlatformResource.create(@platform_hash)
    end

    it 'Verify request after put' do
      new_uri = 'http://localhost:3000/basic_resources/3/components/3/collect'
      @platform_hash[:uri] = new_uri
      put :update,
                params: { uuid: @platform_hash[:uuid], data: @platform_hash }
      expect(response.status).to eq(201)
    end

    message = 'Verify request after put 2'
    verify = :uri
    new_value = 'http://localhost:3000/basic_resources/3/components/3/collect'
    include_examples 'params put', verify, new_value, message

    message = 'Verify if status update correctly'
    verify = :status
    new_value = 'blablabla'
    include_examples 'params put', verify, new_value, message

    message = 'Verify if collect_interval update correctly'
    verify = :collect_interval
    new_value = 360
    include_examples 'params put', verify, new_value, message

    it 'Verify if uuid update correctly' do
      new_uuid = SecureRandom.uuid
      original_uuid = @platform_hash[:uuid]
      @platform_hash[:uuid] = new_uuid
      put :update, params: { uuid: original_uuid, data: @platform_hash }
      platform = PlatformResource.last
      expect(platform.uuid).to eq(new_uuid)
    end

    it 'Verify if wrong uuid raise exception' do
      new_status = 'off_xpto'
      @platform_hash[:status] = new_status
      wrong_uuid = 'notvalid'
      put :update, params: { uuid: wrong_uuid, data: @platform_hash }
      expect(response.status).to eq(404)
    end

    it 'Typo should be recognized' do
      uuid = @platform_hash[:uuid]
      @platform_hash.delete(:status)
      @platform_hash[:stratussss] = 'veryinvalid'
      old_platform = PlatformResource.last
      put :update, params: { uuid: uuid, data: @platform_hash }
      platform = PlatformResource.last
      expect(platform).to eq(old_platform)
    end

    after :each do
      remove = PlatformResource.last
      remove.delete
      @platform_hash = nil
    end
  # End of context
  end

  context 'Verify update method by PUT using data with no capabilities' do

    RSpec.shared_examples 'change data and verify' do |hash_capability, desc|
      it ": #{desc}" do
        new_capability = hash_capability
        put :update,
                  params: { uuid: new_capability[:uuid], data: new_capability }
        expect(response.status).to eq(201)
        platform = PlatformResource.last
        capability_array = []
        platform.capabilities.each do |capability|
          capability_array.push (capability.name)
        end
        expect(capability_array).to match_array(new_capability[:capabilities])
      end
    end

    before :each do
      @platform_hash = with_capability_params
      capabilities = @platform_hash[:capabilities]
      @platform_hash.delete(:capabilities)
      platform = PlatformResource.new(@platform_hash)
      platform.save
      capabilities.each do |name|
        tmp = Capability.new(name: name)
        tmp.save
        platform.capabilities << tmp
      end
    end

    message = 'Update resource with capabilities inside PUT'
    input = FactoryGirl.attributes_for (:with_capability)
    include_examples 'change data and verify', input, message

    message = 'Update resource without capabilities inside PUT'
    input = FactoryGirl.attributes_for (:empty_capability)
    include_examples 'change data and verify', input, message

    message = 'Update resource that changes all capabilities'
    input = FactoryGirl.attributes_for (:with_capability_second)
    include_examples 'change data and verify', input, message

    message = 'Update resource that changes few capabilities'
    input = FactoryGirl.attributes_for (:with_more_capability)
    include_examples 'change data and verify', input, message

    after :each do
      @platform_hash = nil
    end

  end

end
