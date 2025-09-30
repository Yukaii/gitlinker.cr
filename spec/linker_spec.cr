require "./spec_helper"

describe Gitlinker::Linker do
  describe ".make" do
    it "creates a linker for an existing file in the repository" do
      linker = Gitlinker::Linker.make("README.md")

      linker.should_not be_nil
      if linker
        linker.host.should be_a(String)
        linker.repo.should be_a(String)
        linker.rev.should be_a(String)
        linker.file.should eq("README.md")
      end
    end

    it "returns nil for a non-existent file" do
      linker = Gitlinker::Linker.make("nonexistent_file.txt")
      linker.should be_nil
    end

    it "handles files with spaces in the name" do
      # Create a temporary file with spaces
      test_file = "test file.md"
      begin
        File.write(test_file, "test content")

        linker = Gitlinker::Linker.make(test_file)
        if linker
          linker.file.should match(/test%20file\.md/)
        end
      ensure
        File.delete(test_file) if File.exists?(test_file)
      end
    end

    it "resolves relative paths correctly" do
      linker = Gitlinker::Linker.make("./README.md")

      linker.should_not be_nil
      if linker
        linker.file.should eq("README.md")
      end
    end
  end

  describe "#resolve_key" do
    it "resolves basic properties" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "test.cr",
        default_branch: "main",
        current_branch: "feature"
      )

      linker.resolve_key("org").should eq("testorg")
      linker.resolve_key("repo").should eq("testrepo")
      linker.resolve_key("rev").should eq("abc123")
      linker.resolve_key("file").should eq("test.cr")
    end

    it "resolves line numbers when set" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "test.cr",
        default_branch: "main",
        current_branch: "feature"
      )

      linker.lstart = 10
      linker.lend = 20

      linker.resolve_key("lstart").should eq(10)
      linker.resolve_key("lend").should eq(20)
    end

    it "returns nil for unknown keys" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "test.cr",
        default_branch: "main",
        current_branch: "feature"
      )

      linker.resolve_key("unknown").should be_nil
    end
  end
end