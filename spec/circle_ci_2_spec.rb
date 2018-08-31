# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CircleCi2 do
  let(:downloader) { described_class.new }

  describe "#find_artifacts" do
    let(:sample_coverage_json_string) do
      <<~HEREDOC
      [
        {
        "path" : "home/circleci/tablexi/pechakucha-website/coverage/.resultset.json",
        "pretty_path" : "home/circleci/tablexi/pechakucha-website/coverage/.resultset.json",
        "node_index" : 0,
        "url" : "https://example-gh.circle-artifacts.com/0/home/circleci/tablexi/pechakucha-website/coverage/.resultset.json"
        }
      ]
      HEREDOC
    end

    it "Can find the necessary result file" do
      expect(downloader.matching_urls(JSON.parse(sample_coverage_json_string))).to match_array(["https://example-gh.circle-artifacts.com/0/home/circleci/tablexi/pechakucha-website/coverage/.resultset.json"])
    end
  end
end
