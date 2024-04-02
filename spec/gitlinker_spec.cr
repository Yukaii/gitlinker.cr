require "./spec_helper"

describe Gitlinker::Git do
  it "should run file_has_changed" do
    Gitlinker::Git.file_has_changed("README.md", "HEAD~").should be_a(Bool)
  end
end
