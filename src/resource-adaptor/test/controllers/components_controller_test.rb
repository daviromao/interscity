require 'test_helper'

class ComponentsControllerTest < ActionController::TestCase
  setup do
    @component = components(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:components)
  end

  test "should create component" do
    assert_difference('Component.count') do
      post :create, component: {  }
    end

    assert_response 201
  end

  test "should show component" do
    get :show, id: @component
    assert_response :success
  end

  test "should update component" do
    put :update, id: @component, component: {  }
    assert_response 204
  end

  test "should destroy component" do
    assert_difference('Component.count', -1) do
      delete :destroy, id: @component
    end

    assert_response 204
  end
end
