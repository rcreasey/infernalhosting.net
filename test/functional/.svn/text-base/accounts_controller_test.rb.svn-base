require File.dirname(__FILE__) + '/../test_helper'
require 'accounts_controller'

# Re-raise errors caught by the controller.
class AccountsController; def rescue_action(e) raise e end; end

class AccountsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :accounts

  def setup
    @controller = AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'Account.count' do
      create_account
      assert_response :success
      assert_template 'accounts/processing'
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'Account.count' do
      create_account(:login => nil)
      assert assigns(:account).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'Account.count' do
      create_account(:password => nil)
      assert assigns(:account).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'Account.count' do
      create_account(:password_confirmation => nil)
      assert assigns(:account).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'Account.count' do
      create_account(:email_address => nil)
      assert assigns(:account).errors.on(:email_address)
      assert_response :success
    end
  end
  
  def test_should_activate_user
    assert_nil Account.authenticate('aaron', 'test')
    get :activate, :activation_code => accounts(:aaron).activation_code
    assert_template 'accounts/completed'
    assert_equal accounts(:aaron), Account.authenticate('aaron', 'test')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_equal flash[:notice], "Sorry, but I couldn't activate your account!  Did you follow the link in your welcome email?"
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_equal flash[:notice], "Sorry, but I couldn't activate your account!  Did you follow the link in your welcome email?"
  rescue ActionController::RoutingError
    # well played, sir
  end

  protected
    def create_account(options = {})
      post :create, :account => { :first_name => "Quire", :last_name => "Myre", :phone_number => '(555) 555-5555', 
        :login => 'quire', :email_address => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
