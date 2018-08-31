# frozen_string_literal: true

require 'open-uri'
require 'json'

class CircleCi2
  ARTIFACT_PREFIX = "coverage"

  def download_files
    if ENV["CIRCLE_TOKEN"].nil?
      puts "You must create a Circle CI Artifacts-API token to use this on Circle CI 2.0"
      puts "Please create that, and store the key as CIRCLE_TOKEN"
      return []
    end
    # rubocop:disable Metrics/LineLength
    api_url = "https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{ENV['CIRCLE_BUILD_NUM']}/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}"
    # rubocop:enable Metrics/LineLength
    artifacts = open(api_url)

    paths = matching_urls(JSON.load(artifacts))

    if paths.none?
      puts "No Results Found. Did you store the artifacts with 'store_artifacts'?"
      puts "did you use 'prefix: coverage'?"
      return []
    end

    paths.map do |path|
      JSON.load(open("#{path}?circle-token=#{ENV['CIRCLE_TOKEN']}"))
    end
  end

  def matching_urls(json)
    json.select do |artifact|
      artifact['path'].match("#{ARTIFACT_PREFIX}/.resultset.json")
    end.map do |artifact|
      artifact['url']
    end
  end
end
