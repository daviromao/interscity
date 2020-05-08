# frozen_string_literal: true

require 'rails_helper'
require 'json'

describe ActuatorController, :integration, type: :controller do
  it { is_expected.to use_before_action(:set_page_params) }

  describe 'POST' do
    describe '/commands' do
      let(:response) { { 'success' => [], 'failure' => [] } }
      let(:params) { { data: [1] } }

      before do
        allow(subject).to receive(:render)
        allow(subject).to receive(:apply_command)
      end

      context 'with no error' do
        before do
          post :create, params: params
        end

        it 'is expected to apply commands' do
          expect(subject).to have_received(:apply_command)
        end

        it 'is expected to render a json with the response' do
          expect(subject).to have_received(:render).with(
            json: response, status: :ok
          )
        end
      end

      context 'with an error' do
        before do
          expect(subject).to receive(:apply_command) { raise StandardError }

          post :create, params: params
        end

        it 'is expected to render a json with the error' do
          expect(subject).to have_received(:render).with(
            json: { error: 'StandardError' }, status: :bad_request
          )
        end
      end
    end
  end

  describe 'GET' do
    describe '/commands' do
      let(:commands) { 'a' }

      before do
        allow(subject).to receive(:set_page_params)
        allow(ActuatorCommand).to receive_message_chain(:filter, :recent, :page, :per).and_return(commands)
        allow(subject).to receive(:render)

        get :index
      end

      it 'is expected to render the response' do
        expect(subject).to have_received(:render).with(json: { commands: commands }, status: :ok)
      end
    end
  end

  describe 'private methods' do
    describe 'add_failure' do
      let(:response_failure) { [] }
      let(:params) do
        {
          uuid: 1,
          code: 2,
          error: 3,
          capability: 4,
          value: 5
        }
      end

      before do
        subject.instance_variable_set('@response', 'failure' => response_failure)
        allow(response_failure).to receive(:<<)

        subject.send(:add_failure, *params.values)
      end

      it 'is expected to populate the response with stuff' do
        expect(response_failure).to have_received(:<<).with(**params)
      end
    end

    describe 'create_command' do
      let(:command) { double('command') }
      let(:success_field) { [] }
      let(:uuid) { 1 }
      let(:message) { 'message' }
      let(:params) do
        {
          platform_resource: double('resource', uuid: uuid),
          capability: 3,
          value: 4
        }
      end

      before do
        allow(ActuatorCommand).to receive(:new).and_return(command)
        allow(command).to receive(:save)
      end

      context 'with a successful creation' do
        before do
          allow(command).to receive(:save).and_return(true)
          allow(success_field).to receive(:<<)
          subject.instance_variable_set('@response', 'success' => success_field)

          subject.send(:create_command, *params.values)
        end

        it 'is expected to create an ActuatorCommand' do
          expect(ActuatorCommand).to have_received(:new).with(
            **params, uuid: params[:platform_resource].uuid
          )
        end

        it 'is expected to populate the response success field' do
          expect(success_field).to have_received(:<<).with(command)
        end
      end

      context 'with an error on creation' do
        before do
          expect(command).to receive(:save).and_return(false)
          expect(command).to receive_message_chain(:errors, :full_messages)
            .and_return(message)
          allow(success_field).to receive(:<<)

          allow(subject).to receive(:add_failure)

          subject.send(:create_command, *params.values)
        end

        it 'is expected not to populate the response success field' do
          expect(success_field).not_to have_received(:<<).with(command)
        end

        it 'is expected to populate the response failure field' do
          expect(subject).to have_received(:add_failure).with(
            uuid, 400,
            "Invalid command #{message}",
            params[:capability],
            params[:value]
          )
        end
      end
    end

    describe 'apply_command' do
      let(:actuator) do
        {
          'uuid' => 'uuid',
          'capabilities' => capabilities
        }
      end
      let(:resource) { instance_double('PlatformResource') }

      before do
        allow(PlatformResource).to(receive_message_chain(:where, :first)
                                   .and_return(resource))

        allow(subject).to receive(:add_failure)
        allow(subject).to receive(:create_command)

        allow(resource).to receive(:blank?)
        allow(resource).to receive(:capabilities).and_return([capability])
        allow(resource).to receive(:uuid).and_return('uuid')
      end

      context 'blank resource' do
        let(:capability) { 'capability' }
        let(:capabilities) { { capability => 'a' } }
        let(:value) { capabilities[capability] }

        before do
          allow(resource).to receive(:blank?).and_return(true)

          subject.send(:apply_command, actuator, nil)
        end

        it 'is expected to add a resource not found failure' do
          expect(subject).to have_received(:add_failure).with(
            actuator['uuid'], 404, 'Resource not found',
            capability, value
          )
        end
      end

      context 'when the actuator capability is available on the resource' do
        let(:capability) { 'capability' }
        let(:capabilities) { { capability => 'a' } }
        let(:value) { capabilities[capability] }

        before do
          subject.send(:apply_command, actuator, nil)
        end

        it 'is expected to create a command' do
          expect(subject).to have_received(:create_command).with(resource, capability, value)
        end
      end

      context 'when the actuator capability is not included in the resource' do
        let(:capability) { 'capability' }
        let(:capabilities) { { capability => 'a' } }
        let(:value) { capabilities[capability] }

        before do
          allow(resource).to receive(:capabilities).and_return([])
          subject.send(:apply_command, actuator, nil)
        end

        it 'is expected to add not valid capability failure' do
          expect(subject).to have_received(:add_failure).with(
            resource.uuid, 400, 'This resource does not have such capability',
            capability, value
          )
        end
      end
    end

    describe 'set_page_params' do
      it 'is expected not to raise any errors' do
        expect { subject.send(:set_page_params) }.not_to raise_error
      end
    end
  end
end
