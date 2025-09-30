require "./spec_helper"

describe Gitlinker::Configs do
  describe ".routers" do
    it "returns default routers" do
      routers = Gitlinker::Configs.routers
      routers.should be_a(Hash(String, Hash(String, String)))
      routers.keys.should contain("browse")
      routers.keys.should contain("blame")
      routers.keys.should contain("default_branch")
      routers.keys.should contain("current_branch")
    end

    it "includes GitHub patterns" do
      routers = Gitlinker::Configs.routers
      routers["browse"].keys.should contain("^github.com")
      routers["blame"].keys.should contain("^github.com")
    end

    it "includes GitLab patterns" do
      routers = Gitlinker::Configs.routers
      routers["browse"].keys.should contain("^gitlab.com")
    end

    it "includes Bitbucket patterns" do
      routers = Gitlinker::Configs.routers
      routers["browse"].keys.should contain("^bitbucket.org")
    end

    it "includes Codeberg patterns" do
      routers = Gitlinker::Configs.routers
      routers["browse"].keys.should contain("^codeberg.org")
    end
  end

  describe ".setup" do
    it "merges user routers with default routers" do
      user_routers = {
        "browse" => {
          "^custom.com" => "https://custom.com/{org}/{repo}/view/{rev}/{file}#L{lstart}",
        },
      }

      Gitlinker::Configs.setup(user_routers)
      routers = Gitlinker::Configs.routers

      routers["browse"].keys.should contain("^custom.com")
      routers["browse"].keys.should contain("^github.com")
    end

    it "overrides default patterns with user patterns" do
      user_routers = {
        "browse" => {
          "^github.com" => "https://custom-github.com/{org}/{repo}",
        },
      }

      Gitlinker::Configs.setup(user_routers)
      routers = Gitlinker::Configs.routers

      routers["browse"]["^github.com"].should eq("https://custom-github.com/{org}/{repo}")
    end

    it "adds new router types" do
      user_routers = {
        "custom_type" => {
          "^github.com" => "https://github.com/{org}/{repo}/custom/{rev}/{file}",
        },
      }

      Gitlinker::Configs.setup(user_routers)
      routers = Gitlinker::Configs.routers

      routers.keys.should contain("custom_type")
      routers["custom_type"]["^github.com"].should eq("https://github.com/{org}/{repo}/custom/{rev}/{file}")
    end
  end
end