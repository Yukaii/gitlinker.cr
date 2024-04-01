require "process"

def git_command(args)
  stdout = IO::Memory.new
  process = Process.new("git", args, output: stdout, chdir: get_git_root)

  status = process.wait
  stdout.to_s.strip
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

puts get_rev_name "@{u}"
