require 'test_helper'

class MailServicesControllerTest < ActionController::TestCase
  setup do
    @mail_service = mail_services(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mail_services)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mail_service" do
    assert_difference('MailService.count') do
      post :create, mail_service: { end_date: @mail_service.end_date, mailbox_id: @mail_service.mailbox_id, member_id: @mail_service.member_id, notes: @mail_service.notes, start_date: @mail_service.start_date }
    end

    assert_redirected_to mail_service_path(assigns(:mail_service))
  end

  test "should show mail_service" do
    get :show, id: @mail_service
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mail_service
    assert_response :success
  end

  test "should update mail_service" do
    patch :update, id: @mail_service, mail_service: { end_date: @mail_service.end_date, mailbox_id: @mail_service.mailbox_id, member_id: @mail_service.member_id, notes: @mail_service.notes, start_date: @mail_service.start_date }
    assert_redirected_to mail_service_path(assigns(:mail_service))
  end

  test "should destroy mail_service" do
    assert_difference('MailService.count', -1) do
      delete :destroy, id: @mail_service
    end

    assert_redirected_to mail_services_path
  end
end
