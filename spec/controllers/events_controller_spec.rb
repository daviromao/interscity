require 'rails_helper'

describe EventsController, :type => :controller do

  let(:event) { create(:event) }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  # GET /events
  describe "GET :index" do
    it "assigns @events" do
      get :index
      expect(assigns(:events)).to eq([event])
    end

    it "renders the events index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "returns a 200 status code when accessing normally" do
      get :index
      expect(response.status).to eq(200)
    end

    it "returns a 400 status code when sending invalid pagination arguments" do
      # Lists of invalid arguments
      err_limit = [-1, 1.23, "foobar"]
      err_start = [-4, 9.87, "barfoo"]

      # Expect errors with all combinations of invalid arguments
      err_limit.each do |limit|
        get :index, params: { limit: limit }
        expect(response.status).to eq(400)

        err_start.each do |start|
          get :index, params: { start: start }
          expect(response.status).to eq(400)

          get :index, params: { limit: limit, start: start }
          expect(response.status).to eq(400)
        end
      end
    end

    it "Returns a 400 status code when sending invalid data ranges argunments" do
     # List of invalid arguments
     err_data = ["foobar", 9.68]
     # Expect errors with all combinations of invalid arguments
     err_data.each do |data|
       get :index, params: {start_range: data, end_range: data}
       expect(response.status).to eq(400)
     end
    end
  end

  describe "GET :index to json" do
    it "returns a json object array" do
      get :index
      expect(response.content_type).to eq("application/json")
    end
  end

  # GET /events/:event_id
  describe "GET :show" do
    it "renders the event show template" do
      get :show, params: { id: event.id }
      expect(response).to render_template("show")
    end

    it "returns a 200 status code when requesting correctly" do
      get :show, params: { id: event.id }
      expect(response.status).to eq(200)
    end

    it "returns a 400 status code when sending an invalid 'event_id'" do
      # List of invalid arguments
      err_ids = [-5, 2.3, "foobar"]

      err_ids.each do |id|
        get :show, params: { id: id }
        expect(response.status).to eq(400)
      end
    end
  end

  describe "GET :show to json" do
    it "returns a json object " do
      get :show, params: { id: event.id }
      expect(response.content_type).to eq("application/json")
    end
  end

  context "with render_views" do
    render_views

    before :each do
      headers = {
        "ACCEPT" => "application/json"
      }
    end

    describe "GET :index" do
      it "renders the correct json and completes the url route" do
        get :index, :format => :json
        expect(response).to render_template(:index)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq("application/json")
      end

      it "filter the events by capability" do
        get :index, :format => :json, params: { capability: 'temperature' }
        expect(response).to render_template(:index)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end

      it "Filter the events by date range" do
        get :index, :format => :json,
            params: {
              start_range: '2016-06-03T13:18:57',
              end_range: '2016-06-03T13:25:00'
            }
        expect(response).to render_template(:index)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
      end
   end

    describe "GET :show" do
      it "renders the correct json and completes the url route" do
        get :show, :format => :json, params: { id: event.id }
        expect(response).to render_template(:show)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq("application/json")
      end
    end
  end
end
