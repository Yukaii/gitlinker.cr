require "./spec_helper"

describe Gitlinker::GitUrlParser do
  describe ".parse" do
    it "parses a URL with protocol, user, password, host, port, org, repo, and path" do
      url = "https://user:password@example.com:8080/org/repo"
      result, error = Gitlinker::GitUrlParser.parse(url)

      result.should_not be_nil
      error.should be_nil

      result = result.not_nil!
      result.protocol.should eq("https")
      result.user.should eq("user")
      result.password.should eq("password")
      result.host.should eq("example.com")
      result.port.should eq("8080")
      result.org.should eq("org")
      result.repo.should eq("repo")
      result.path.should eq("/org/repo")
    end

    it "parses a URL with protocol, host, org, and repo" do
      url = "https://example.com/org/repo"
      result, error = Gitlinker::GitUrlParser.parse(url)

      result.should_not be_nil
      error.should be_nil

      result = result.not_nil!
      result.protocol.should eq("https")
      result.host.should eq("example.com")
      result.org.should eq("org")
      result.repo.should eq("repo")
      result.path.should eq("/org/repo")
    end

    # it "parses a URL with user, host, and path (SSH protocol omitted)" do
    #   url = "user@example.com/path/to/repo.git"
    #   result, error = Gitlinker::GitUrlParser.parse(url)

    #   result.should_not be_nil
    #   error.should be_nil

    #   result = result.not_nil!
    #   result.user.should eq("user")
    #   result.host.should eq("example.com")
    #   result.path.should eq("/path/to/repo.git")
    # end

    # it "parses a URL with only path (local file path)" do
    #   url = "/path/to/repo"
    #   result, error = Gitlinker::GitUrlParser.parse(url)

    #   result.should_not be_nil
    #   error.should be_nil

    #   result = result.not_nil!
    #   result.path.should eq("/path/to/repo")
    # end

    it "returns an error for an empty URL" do
      url = ""
      result, error = Gitlinker::GitUrlParser.parse(url)

      result.should be_nil
      error.should eq("empty string")
    end
  end
end
