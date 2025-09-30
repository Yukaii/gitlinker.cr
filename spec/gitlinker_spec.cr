require "./spec_helper"

describe Gitlinker::Git do
  it "should run file_has_changed" do
    Gitlinker::Git.file_has_changed("README.md", "HEAD~").should be_a(Bool)
  end

  it "should get the git root directory" do
    Gitlinker::Git.get_git_root.should be_a(String)
  end

  it "should get the list of remotes" do
    Gitlinker::Git.get_remotes.should be_a(String | Nil)
  end

  it "should get the remote URL" do
    remotes = Gitlinker::Git.get_remotes
    if remotes
      remote = remotes.split("\n").first
      Gitlinker::Git.get_remote_url(remote).should be_a(String)
    else
      pending("No remotes found in the repository")
    end
  end

  it "should get the name of a revision" do
    Gitlinker::Git.get_rev_name("HEAD").should be_a(String)
  end

  it "should get the hash of a revision" do
    Gitlinker::Git.get_rev("HEAD").should be_a(String)
  end

  it "should check if a file is in a revision" do
    Gitlinker::Git.is_file_in_rev("README.md", "HEAD").should be_true
  end

  it "should check if a revision is in a remote" do
    remotes = Gitlinker::Git.get_remotes
    if remotes
      remote = remotes.split("\n").first
      Gitlinker::Git.is_rev_in_remote("HEAD", remote).should be_a(Bool)
    else
      pending("No remotes found in the repository")
    end
  end

  it "should check if a remote has fetch configuration" do
    remotes = Gitlinker::Git.get_remotes
    if remotes
      remote = remotes.split("\n").first
      Gitlinker::Git.has_remote_fetch_config(remote).should be_a(Bool)
    else
      pending("No remotes found in the repository")
    end
  end


  it "should get the closest remote-compatible revision" do
    remotes = Gitlinker::Git.get_remotes
    if remotes
      remote = remotes.split("\n").first
      Gitlinker::Git.get_closest_remote_compatible_rev(remote).should be_a(String)
    else
      pending("No remotes found in the repository")
    end
  end

  it "should get the branch remote" do
    remotes = Gitlinker::Git.get_remotes
    if remotes
      Gitlinker::Git.get_branch_remote.should be_a(String | Nil)
    else
      pending("No remotes found in the repository")
    end
  end

  it "should get the default branch for a remote" do
    remotes = Gitlinker::Git.get_remotes
    if remotes
      remote = remotes.split("\n").first
      Gitlinker::Git.get_default_branch(remote).should be_a(String | Nil)
    else
      pending("No remotes found in the repository")
    end
  end

  it "should get the current branch" do
    Gitlinker::Git.get_current_branch.should be_a(String | Nil)
  end
end
