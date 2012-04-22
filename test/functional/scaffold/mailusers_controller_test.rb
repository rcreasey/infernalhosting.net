require File.dirname(__FILE__) + '/../../test_helper'
require 'scaffold/mailusers_controller'

# Re-raise errors caught by the controller.
class Scaffold::MailusersController; def rescue_action(e) raise e end; end

class Scaffold::MailusersControllerTest < Test::Unit::TestCase
  fixtures :mail_users

  def setup
    @controller = Scaffold::MailusersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:mail_users)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:mail_user)
    assert assigns(:mail_user).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:mail_user)
  end

  def test_create
    num_mail_users = MailUser.count

    post :create, :mail_user => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_mail_users + 1, MailUser.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:mail_user)
    assert assigns(:mail_user).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil MailUser.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      MailUser.find(1)
    }
  end
end
