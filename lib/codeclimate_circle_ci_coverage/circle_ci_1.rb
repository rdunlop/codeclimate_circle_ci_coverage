# frozen_string_literal: true

require 'fileutils'
require 'json'

class CircleCi1
  # Public: Download the .resultset.json files from each of the nodes
  # and store them in the `target_directory`.
  #
  # return: an array of JSON parsed contents of these files.
  #
  # They will be numbered 0.resultset.json, 1.resultset.json, etc.
  def download_files
    node_total = ENV['CIRCLE_NODE_TOTAL'].to_i
    target_directory = File.join("all_coverage")

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

        puts "Downloading Result from CI Node: #{command}"
        `#{command}`
      end
    end

    # Load coverage results from all nodes
    files = Dir.glob(File.join(target_directory, "*.resultset.json"))
    files.map do |file, _i|
      JSON.load(File.read(file))
    end
  end
end
