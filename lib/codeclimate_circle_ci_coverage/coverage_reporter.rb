# from https://github.com/codeclimate/ruby-test-reporter/issues/10
# https://gist.github.com/evanwhalen/f74879e0549b67eb17bb

# Possibly look at:
# http://technology.indiegogo.com/2015/08/how-we-get-coverage-on-parallelized-test-builds/
#
# Questions:
# - Why aren't artifacts stored in the $CIRCLE_ARTIFACTS directory when doing SSH login?
require "codeclimate-test-reporter"
require "simplecov"

# This packages up the code coverage metrics from multiple servers and
# sends them to CodeClimate via the CodeClimate Test Reporter Gem
class CoverageReporter
  attr_reader :target_branch

  def initialize(target_branch)
    @target_branch = target_branch
  end

  def current_branch
    ENV['CIRCLE_BRANCH']
  end

  def current_node
    ENV['CIRCLE_NODE_INDEX'].to_i
  end

  # Returns false if unsuccessful
  # Returns true if successful
  def run
    # Only submit coverage to codeclimate on target branch
    if current_branch != target_branch
      puts "Current branch #{current_branch} is not the target branch #{target_branch}"
      puts "No Coverage will be reported"
      return true
    end

    # Only run on node0
    return true unless current_node.zero?

    json_result_files = download_files
    merged_result = merge_files(json_result_files)

    output_result_html(merged_result)
    upload_result_file(merged_result)
    store_code_climate_payload(merged_result)
    puts "Reporting Complete."
    true
  end

  def download_files
    if ENV["CIRCLE_JOB"].nil?
      CircleCi1.new.download_files
    else
      CircleCi2.new.download_files
    end
  end

  def merge_files(json_files)
    SimpleCov.coverage_dir('/tmp/coverage')

    # Merge coverage results from all nodes
    json_files.each_with_index do |resultset, i|
      resultset.each do |_command_name, data|
        result = SimpleCov::Result.from_hash(['command', i].join => data)
        check_and_fix_result_time(result, i)
        SimpleCov::ResultMerger.store_result(result)
      end
    end

    merged_result = SimpleCov::ResultMerger.merged_result
    merged_result.command_name = 'RSpec'
    merged_result
  end

  def check_and_fix_result_time(result, index)
    if Time.now - result.created_at >= SimpleCov.merge_timeout
      puts "result #{index} has a created_at from #{result.created_at} (current time #{Time.now})"
      puts "This will prevent coverage from being combined. Please check your tests for Stub-Time-related issues"
      puts "Setting result created_at to current time to avoid this issue"
      # If the result is timestamped old, it is ignored by SimpleCov
      # So we always set the created_at to Time.now so that the ResultMerger
      # doesn't discard any results
      result.created_at = Time.now
    end
  end

  def output_result_html(merged_result)
    # Format merged result with html
    html_formatter = SimpleCov::Formatter::HTMLFormatter.new
    html_formatter.format(merged_result)
  end

  def upload_result_file(merged_result)
    # Post merged coverage result to codeclimate
    codeclimate_formatter = CodeClimate::TestReporter::Formatter.new
    codeclimate_formatter.format(merged_result.to_hash)
  end

  # Internal: Debug function, in use to log the exact file which is sent to codeclimate
  # for use when troubleshooting.
  def store_code_climate_payload(merged_result)
    ENV["CODECLIMATE_TO_FILE"] = "true"
    codeclimate_formatter = CodeClimate::TestReporter::Formatter.new
    codeclimate_formatter.format(merged_result.to_hash)
  ensure
    ENV["CODECLIMATE_TO_FILE"] = nil
  end
end
