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

      remote = Git.get_branch_remote
      return nil unless remote

      remote_url = Git.get_remote_url(remote)
      return nil unless remote_url

      uri = URI.parse(remote_url)
      host = uri.host
      return nil unless host

      rev = Git.get_closest_remote_compatible_rev(remote)
      return nil unless rev

      file = URI.encode_path(file_path)

      file_in_rev = Git.is_file_in_rev(file_path, rev)
      return nil unless file_in_rev

      file_changed = Git.file_has_changed(file_path, rev)

      default_branch = Git.get_default_branch(remote)
      current_branch = Git.get_current_branch

      new(
        remote_url,
        uri.scheme,
        uri.user,
        uri.password,
        host,
        uri.port.to_s,
        uri.path.split("/")[1],
        uri.path.split("/")[2],
        rev,
        file,
        file_changed,
        default_branch,
        current_branch
      )
    end
  end
end
