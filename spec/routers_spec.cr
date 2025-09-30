require "./spec_helper"

describe Gitlinker::Routers do
  describe ".generate_url" do
    it "generates a GitHub browse URL with single line" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should eq("https://github.com/testorg/testrepo/blob/abc123/src/test.cr#L10")
    end

    it "generates a GitHub browse URL with line range" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10
      linker.lend = 20

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should eq("https://github.com/testorg/testrepo/blob/abc123/src/test.cr#L10-L20")
    end

    it "generates a GitHub blame URL" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10

      url = Gitlinker::Routers.generate_url(linker, "blame")
      url.should eq("https://github.com/testorg/testrepo/blame/abc123/src/test.cr#L10")
    end

    it "generates a GitLab browse URL" do
      linker = Gitlinker::Linker.new(
        host: "gitlab.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10
      linker.lend = 20

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should eq("https://gitlab.com/testorg/testrepo/blob/abc123/src/test.cr#L10-L20")
    end

    it "generates a Bitbucket browse URL" do
      linker = Gitlinker::Linker.new(
        host: "bitbucket.org",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10
      linker.lend = 20

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should eq("https://bitbucket.org/testorg/testrepo/src/abc123/src/test.cr#lines-10:20")
    end

    it "generates a Codeberg browse URL" do
      linker = Gitlinker::Linker.new(
        host: "codeberg.org",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10
      linker.lend = 20

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should eq("https://codeberg.org/testorg/testrepo/src/commit/abc123/src/test.cr#L10-L20")
    end

    it "strips .git suffix from repo names" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo.git",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )
      linker.lstart = 10

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should eq("https://github.com/testorg/testrepo/blob/abc123/src/test.cr#L10")
    end

    it "returns nil for unknown host" do
      linker = Gitlinker::Linker.new(
        host: "unknown.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )

      url = Gitlinker::Routers.generate_url(linker, "browse")
      url.should be_nil
    end

    it "returns nil for unknown router type" do
      linker = Gitlinker::Linker.new(
        host: "github.com",
        org: "testorg",
        repo: "testrepo",
        rev: "abc123",
        file: "src/test.cr",
        default_branch: "main",
        current_branch: "feature"
      )

      url = Gitlinker::Routers.generate_url(linker, "unknown")
      url.should be_nil
    end
  end
end