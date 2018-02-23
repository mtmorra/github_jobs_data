require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test 'Github Jobs service is available' do
    response = HTTParty.get(Github::Jobs::Client::BASE_URL)
    assert response.success?
  end

  test 'positions returns job objects' do
    jobs = Github::Jobs::Client.positions
    jobs.all?{|j| j.is_a?(Job)}
  end
end