require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  test "should get get_news" do
    get :get_news
    assert_response :success
  end

  test "should get trends" do
    get :trends
    assert_response :success
  end

end
