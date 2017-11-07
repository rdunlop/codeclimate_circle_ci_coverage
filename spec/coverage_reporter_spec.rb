require 'spec_helper'

describe CoverageReporter do
  let(:reporter) { described_class.new("master") }

  describe "#run" do
    let(:sample_coverage) do
      [
        {
          "RSpec" => {
            "coverage" => {
              "#{SimpleCov.root}/spec/fixtures/fake_project/fake_project.rb" => [5,3,nil,0]
            },
            "timestamp" => Time.now.to_i,
          }
        }
      ]
    end

    it "returns true on mismatch branch names" do
      allow(reporter).to receive(:current_branch).and_return("develop")
      expect(reporter.run).to be_truthy
    end

    it "returns true on incorrect node number" do
      allow(reporter).to receive(:current_branch).and_return("master")
      allow(reporter).to receive(:current_node).and_return(1)
      expect(reporter.run).to be_truthy
    end

    xit "returns true when branch and node are correct" do
      allow(reporter).to receive(:current_branch).and_return("master")
      allow(reporter).to receive(:current_node).and_return(0)
      allow_any_instance_of(CircleCi1).to receive(:download_files).and_return(sample_coverage)
      expect(reporter.run).to be_truthy
      # failing because creating a believable SimpleCov Result is more difficult than I thought
    end
  end

  describe "#check_and_fix_result_time" do
    context "when the time is new enough" do
      let(:result) { OpenStruct.new(created_at: Time.now) }

      it "does nothing" do
        reporter.check_and_fix_result_time(result, 1)
        expect(result.created_at).to be_within(1).of(Time.now)
      end
    end

    context "when the time is in the past" do
      let(:result) { OpenStruct.new(created_at: Time.now - 3600) }
      it "can fix times" do
        reporter.check_and_fix_result_time(result, 1)
        expect(result.created_at).to be_within(1).of(Time.now)
      end
    end
  end
end
