require "process"

module Gitlinker
  module Git
    extend self

    def git_command(args)
      stdout = IO::Memory.new
      process = Process.new("git", args, output: stdout, chdir: get_git_root)

      status = process.wait
      if status.success?
        stdout.to_s.strip
      else
        nil
      end
    end

    def get_git_root
      `git rev-parse --show-toplevel`.strip
    end

    def get_remotes
      git_command(["remote"])
    end

    def get_remote_url(remote : String)
      git_command(["remote", "get-url", remote])
    end

    def get_rev_name(rev)
      git_command(["rev-parse", "--abbrev-ref", rev])
    end

    def get_rev(rev)
      git_command(["rev-parse", rev])
    end

    def is_file_in_rev(file, revspec)
      output = git_command(["cat-file", "-e", "#{revspec}:#{file}"])
      !output.nil?
    end

    def file_has_changed(file, rev)
      !git_command(["diff", rev, "--", file]).nil?
    end

    def is_rev_in_remote(revspec, remote)
      raise "remote required" if !remote

      raw_branches = git_command(["branch", "--remotes", "--contains", revspec])

      if raw_branches.nil?
        return false
      end

      branches = raw_branches.split("\n").map(&.strip)
      branches.any? { |b| Regex.new(remote).match(b) }
    end

    def has_remote_fetch_config(remote)
      output = git_command(["config", "remote.#{remote}.fetch"])
      output && !output.empty?
    end

    def resolve_host(host)
      output = git_command(["ssh", "-ttG", host])
      return host if output.nil?

      stdout_map = output.split("\n").reduce({} of String => String) do |map, item|
        key, value = item.split(/\s+/, 2)
        map[key] = value.strip if key && value
        map
      end

      stdout_map["hostname"]? || host
    end

    def get_closest_remote_compatible_rev(remote)
      raise "remote required" if !remote

      upstream_rev = get_rev("@{u}")
      return upstream_rev if upstream_rev

      remote_fetch_configured = has_remote_fetch_config(remote)

      if remote_fetch_configured
        return get_rev("HEAD") if is_rev_in_remote("HEAD", remote)
      else
        head_rev = get_rev("HEAD")
        return head_rev if head_rev
      end

      if remote_fetch_configured
        (1..50).each do |i|
          revspec = "HEAD~#{i}"
          return get_rev(revspec) if is_rev_in_remote(revspec, remote)
        end
      else
        (1..50).each do |i|
          revspec = "HEAD~#{i}"
          rev = get_rev(revspec)
          return rev if rev
        end
      end

      get_rev(remote)
    end

    def get_branch_remote
      remotes = get_remotes
      return nil if remotes.nil?

      remote_list = remotes.split("\n").map(&.strip)
      # If there is more than one remote, try to determine the one associated with the upstream branch.
      if remote_list.size > 1
        upstream_branch = get_rev_name("@{u}")
        if upstream_branch.nil?
          # Fall back if no upstream is set (e.g. new branch)
          return remote_list.first
        end

        upstream_branch_allowed_chars = /[_\-\w\.]+/
        match_data = upstream_branch.match(/^(#{upstream_branch_allowed_chars})\//)
        remote_from_upstream_branch = match_data ? match_data[1] : nil
        # Fallback to first remote if upstream remote not found.
        remote_from_upstream_branch || remote_list.first
      else
        remote_list.first
      end
    end

    def get_default_branch(remote)
      output = git_command(["rev-parse", "--abbrev-ref", "#{remote}/HEAD"])
      output.split("/").last if output
    end

    def get_current_branch
      get_rev_name("HEAD")
    end
  end
end
