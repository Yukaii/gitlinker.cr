require "uri"

module Gitlinker
  class Linker
    property remote_url : String
    property protocol : String?
    property username : String?
    property password : String?
    property host : String
    property port : String?
    property org : String?
    property repo : String
    property rev : String
    property file : String
    property lstart : Int32?
    property lend : Int32?
    property file_changed : Bool
    property default_branch : String?
    property current_branch : String?

    def initialize(
      @remote_url,
      @protocol,
      @username,
      @password,
      @host,
      @port,
      @org,
      @repo,
      @rev,
      @file,
      @file_changed,
      @default_branch,
      @current_branch
    )
    end

    def self.make(file_path : String)
      cwd = Dir.current

      root = Git.get_git_root
      return nil unless root

      # Compose to absolute path first
      absolute_path = File.expand_path(file_path, cwd)

      # Check if the file exists using the absolute path
      return nil unless File.exists?(absolute_path)

      # Convert to relative path to project root
      relative_path = Path[absolute_path].relative_to(root).to_s

      remote = Git.get_branch_remote
      return nil unless remote

      remote_url = Git.get_remote_url(remote)
      return nil unless remote_url

      uri, err = GitUrlParser.parse(remote_url)
      return nil unless uri && uri.host && uri.repo
      host = uri.host.not_nil!
      repo = uri.repo.not_nil!

      rev = Git.get_closest_remote_compatible_rev(remote)
      return nil unless rev

      file = URI.encode_path(relative_path)

      file_in_rev = Git.is_file_in_rev(relative_path, rev)
      return nil unless file_in_rev

      file_changed = Git.file_has_changed(relative_path, rev)

      default_branch = Git.get_default_branch(remote)
      current_branch = Git.get_current_branch

      new(
        remote_url,
        uri.protocol,
        uri.user,
        uri.password,
        host,
        uri.port.to_s,
        uri.org,
        repo,
        rev,
        file,
        file_changed,
        default_branch,
        current_branch
      )
    end

    def resolve_key(key)
      case key
      when "org"
        org
      when "repo"
        repo
      when "rev"
        rev
      when "file"
        file
      when "lstart"
        lstart.try(&.to_i)
      when "lend"
        lend.try(&.to_i)
      else
        nil
      end
    end
  end
end
