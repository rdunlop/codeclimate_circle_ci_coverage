require 'spec_helper'

describe CoverageReporter do
  let(:reporter) { described_class.new("master") }

  describe "#run" do
    it "returns true on mismatch branch names" do
      allow(reporter).to receive(:current_branch).and_return("develop")
      expect(reporter.run).to be_truthy
    end

    it "returns true on incorrect node number" do
      allow(reporter).to receive(:current_branch).and_return("master")
      allow(reporter).to receive(:current_node).and_return(1)
      expect(reporter.run).to be_truthy
    end

    it "returns true when branch and node are correct" do
      allow(reporter).to receive(:current_branch).and_return("master")
      allow(reporter).to receive(:current_node).and_return(0)
      expect(reporter.run).to be_truthy
    end
  end
end
