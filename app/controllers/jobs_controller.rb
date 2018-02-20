class JobsController < ApplicationController

  def summary
    @jobs = Github::Jobs::Client.positions
  end

end
