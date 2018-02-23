class JobsController < ApplicationController

  def summary
    @total_jobs = 0
    @jobs_summary_hash = {}
    jobs = Github::Jobs::Client.positions
    jobs.each do |job|
      @total_jobs += 1 # Total Sourced Jobs
      job_summary_hash = job.cities_summary
      @jobs_summary_hash.deep_merge!(job_summary_hash){ |_key, sum, additive| sum + additive }
    end
  end

end
