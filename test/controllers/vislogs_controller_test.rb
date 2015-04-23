require 'test_helper'

class VislogsControllerTest < ActionController::TestCase
  setup do
    @vislog = vislogs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vislogs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vislog" do
    assert_difference('Vislog.count') do
      post :create, vislog: { data: @vislog.data, user_id: @vislog.user_id, visualization_id: @vislog.visualization_id }
    end

    assert_redirected_to vislog_path(assigns(:vislog))
  end

  test "should show vislog" do
    get :show, id: @vislog
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vislog
    assert_response :success
  end

  test "should update vislog" do
    patch :update, id: @vislog, vislog: { data: @vislog.data, user_id: @vislog.user_id, visualization_id: @vislog.visualization_id }
    assert_redirected_to vislog_path(assigns(:vislog))
  end

  test "should destroy vislog" do
    assert_difference('Vislog.count', -1) do
      delete :destroy, id: @vislog
    end

    assert_redirected_to vislogs_path
  end
end
