class JobsControllerTest < ActionDispatch::IntegrationTest
  test "should get summary" do
    get summary_jobs_url
    assert_response :success
  end
end