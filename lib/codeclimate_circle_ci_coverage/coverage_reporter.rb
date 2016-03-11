# from https://github.com/codeclimate/ruby-test-reporter/issues/10
# https://gist.github.com/evanwhalen/f74879e0549b67eb17bb

# Possibly look at:
# http://technology.indiegogo.com/2015/08/how-we-get-coverage-on-parallelized-test-builds/
#
# Questions:
# - Why aren't artifacts stored in the $CIRCLE_ARTIFACTS directory when doing SSH login?
require "codeclimate-test-reporter"
require "simplecov"
require 'fileutils'

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

  def run
    # Only submit coverage to codeclimate on target branch
    return if current_branch != target_branch
    # Only run on node0
    return unless current_node.zero?

    all_coverage_dir = File.join("all_coverage")
    download_files(all_coverage_dir)
    final_coverage_dir = File.join("combined_coverage")

    merged_result = load_and_merge_files(all_coverage_dir, final_coverage_dir)
    output_result_html(merged_result)
    upload_result_file(merged_result)
    store_code_climate_payload(merged_result)
  end

  # Public: Download the .resultset.json files from each of the nodes
  # and store them in the `target_directory`
  #
  # They will be numbered 0.resultset.json, 1.resultset.json, etc.
  def download_files(target_directory)
    node_total = ENV['CIRCLE_NODE_TOTAL'].to_i

    # Create directory if it doesn't exist
    FileUtils.mkdir_p target_directory

    if node_total > 0
      # Copy coverage results from all nodes to circle artifacts directory
      0.upto(node_total - 1) do |i|
        node = "node#{i}"
        # Modified because circleCI doesn't appear to deal with artifacts in the expected manner
        node_project_dir = `ssh #{node} 'printf $CIRCLE_PROJECT_REPONAME'`
        from = File.join("~/", node_project_dir, 'coverage', ".resultset.json")
        to = File.join(target_directory, "#{i}.resultset.json")
        command = "scp #{node}:#{from} #{to}"

        puts "running command: #{command}"
        `#{command}`
      end
    end
  end

  def load_and_merge_files(source_directory, target_directory)
    FileUtils.mkdir_p target_directory
    SimpleCov.coverage_dir(target_directory)

    # Merge coverage results from all nodes
    files = Dir.glob(File.join(source_directory, "*.resultset.json"))
    files.each_with_index do |file, i|
      resultset = JSON.load(File.read(file))
      resultset.each do |_command_name, data|
        result = SimpleCov::Result.from_hash(['command', i].join => data)

        puts "Resetting result #{i} created_at from #{result.created_at} to #{Time.now}"
        # It appears that sometimes the nodes provided by CircleCI have
        # clocks which are not accurate/synchronized
        # So we always set the created_at to Time.now so that the ResultMerger
        # doesn't discard any results
        result.created_at = Time.now

        SimpleCov::ResultMerger.store_result(result)
      end
    end

    merged_result = SimpleCov::ResultMerger.merged_result
    merged_result.command_name = 'RSpec'
    merged_result
  end

  def output_result_html(merged_result)
    # Format merged result with html
    html_formatter = SimpleCov::Formatter::HTMLFormatter.new
    html_formatter.format(merged_result)
  end

  def upload_result_file(merged_result)
    # Post merged coverage result to codeclimate
    codeclimate_formatter = CodeClimate::TestReporter::Formatter.new
    codeclimate_formatter.format(merged_result)
  end

  # Internal: Debug function, in use to try to determine why codeclimate
  # is marking some lines of comments as "relevant" lines.
  def store_code_climate_payload(merged_result)
    ENV["CODECLIMATE_TO_FILE"] = "true"
    codeclimate_formatter = CodeClimate::TestReporter::Formatter.new
    codeclimate_formatter.format(merged_result)
  ensure
    ENV["CODECLIMATE_TO_FILE"] = nil
  end
end
