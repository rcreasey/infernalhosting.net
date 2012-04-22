require File.dirname(__FILE__) + '/../test_helper'
require 'suspended_controller'

# Re-raise errors caught by the controller.
class SuspendedController; def rescue_action(e) raise e end; end

class SuspendedControllerTest < Test::Unit::TestCase
  def setup
    @controller = SuspendedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
