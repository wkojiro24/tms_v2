require "test_helper"

class VehicleAliasesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get vehicle_aliases_create_url
    assert_response :success
  end

  test "should get destroy" do
    get vehicle_aliases_destroy_url
    assert_response :success
  end
end
