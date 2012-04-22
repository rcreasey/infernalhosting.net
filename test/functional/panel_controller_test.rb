require File.dirname(__FILE__) + '/../test_helper'
require 'panel_controller'

# Re-raise errors caught by the controller.
class PanelController; def rescue_action(e) raise e end; end

class PanelControllerTest < Test::Unit::TestCase
  def setup
    @controller = PanelController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
