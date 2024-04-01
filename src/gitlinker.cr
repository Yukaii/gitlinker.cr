require "process"

module Gitlinker
  VERSION = "0.1.0"

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
    git_command ["remote"]
  end

  def get_remote_url(remote : String)
    git_command ["remote", "get-url", remote]
  end

  def get_rev_name(rev)
    git_command ["rev-parse", "--abbrev-ref", rev]
  end

  def get_rev(rev)
    git_command ["rev-parse", rev]
  end

  def is_file_in_rev(file, revspec)
    output = git_command ["cat-file", "-e", "#{revspec}:#{file}"]
    !output.nil?
  end

  def has_file_changed(file, rev)
    !(git_command ["diff", rev, "--", file]).nil?
  end

  def is_rev_in_remote(revspec, remote)
    raise "remote required" if !remote

    raw_branches = git_command ["branch", "--remotes", "--contains", revspec]

    if raw_branches.nil?
      return false
    end

    branches = raw_branches.split("\n").map { |i| i.strip }
    branches.any? { |b| Regex.new(remote).match(b) }
  end
end
