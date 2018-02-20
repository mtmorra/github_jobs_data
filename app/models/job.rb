class Job
  include ActiveModel::Model
  attr_accessor :id, :location, :description

  CITIES = ["Boston", "San Francisco", "Los Angeles", "Denver", "Boulder", "Chicago", "New York"]

  def initialize(params)
    @id = params["id"]
    @location = params["location"]
    @description = params["description"]
  end
end