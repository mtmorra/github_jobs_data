require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test 'Github Jobs service is available' do
    response = HTTParty.get(Github::Jobs::Client::BASE_URL)
    assert response.success?
  end
end