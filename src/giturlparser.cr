module Gitlinker
  module GitUrlParser
    record GitUrlPos, start_pos : Int32?, end_pos : Int32?

    record GitUrlInfo,
      protocol : String?,
      protocol_pos : GitUrlPos?,
      user : String?,
      user_pos : GitUrlPos?,
      password : String?,
      password_pos : GitUrlPos?,
      host : String?,
      host_pos : GitUrlPos?,
      port : String?,
      port_pos : GitUrlPos?,
      org : String?,
      org_pos : GitUrlPos?,
      repo : String?,
      repo_pos : GitUrlPos?,
      path : String?,
      path_pos : GitUrlPos?

    private record GitUrlPath,
      org : String?,
      org_pos : GitUrlPos?,
      repo : String?,
      repo_pos : GitUrlPos?,
      path : String?,
      path_pos : GitUrlPos?

    private record GitUrlHost,
      host : String?,
      host_pos : GitUrlPos?,
      port : String?,
      port_pos : GitUrlPos?,
      path_obj : GitUrlPath

    private record GitUrlUser,
      user : String?,
      user_pos : GitUrlPos?,
      password : String?,
      password_pos : GitUrlPos?,
      host_obj : GitUrlHost

    def self.parse(url : String) : {GitUrlInfo?, String?}
      if url.empty?
        return {nil, "empty string"}
      end

      protocol_delimiter_pos = url.index("://")
      if protocol_delimiter_pos
        protocol, protocol_pos = make(url, 0, protocol_delimiter_pos + 2) # Include the "://" in the protocol

        user_obj = parse_user(url, protocol_delimiter_pos + 3)
        host_obj = user_obj.host_obj
        path_obj = host_obj.path_obj

        return {
          GitUrlInfo.new(
            protocol: protocol,
            protocol_pos: protocol_pos,
            user: user_obj.user,
            user_pos: user_obj.user_pos,
            password: user_obj.password,
            password_pos: user_obj.password_pos,
            host: host_obj.host,
            host_pos: host_obj.host_pos,
            port: host_obj.port,
            port_pos: host_obj.port_pos,
            org: path_obj.org,
            org_pos: path_obj.org_pos,
            repo: path_obj.repo,
            repo_pos: path_obj.repo_pos,
            path: path_obj.path,
            path_pos: path_obj.path_pos
          ),
          nil
        }
      else
        first_colon_pos = url.index(':')
        if first_colon_pos && first_colon_pos > 1
          user_obj = parse_user(url, 1, ssh_protocol_omitted: true)
          host_obj = user_obj.host_obj
          path_obj = host_obj.path_obj

          return {
            GitUrlInfo.new(
              protocol: nil,
              protocol_pos: nil,
              user: user_obj.user,
              user_pos: user_obj.user_pos,
              password: user_obj.password,
              password_pos: user_obj.password_pos,
              host: host_obj.host,
              host_pos: host_obj.host_pos,
              port: host_obj.port,
              port_pos: host_obj.port_pos,
              org: path_obj.org,
              org_pos: path_obj.org_pos,
              repo: path_obj.repo,
              repo_pos: path_obj.repo_pos,
              path: path_obj.path,
              path_pos: path_obj.path_pos
            ),
            nil
          }
        else
          path_obj = parse_path(url, 1)
          return {
            GitUrlInfo.new(
              protocol: nil,
              protocol_pos: nil,
              user: nil,
              user_pos: nil,
              password: nil,
              password_pos: nil,
              host: nil,
              host_pos: nil,
              port: nil,
              port_pos: nil,
              org: path_obj.org,
              org_pos: path_obj.org_pos,
              repo: path_obj.repo,
              repo_pos: path_obj.repo_pos,
              path: path_obj.path,
              path_pos: path_obj.path_pos
            ),
            nil
          }
        end
      end
    end

    private def self.make(url : String, start_pos : Int32, end_pos : Int32) : {String, GitUrlPos}
      pos = GitUrlPos.new(start_pos: start_pos, end_pos: end_pos)
      component = url[start_pos..end_pos]
      {component, pos}
    end

    private def self.trim_slash(val : String, pos : GitUrlPos) : {String, GitUrlPos}
      if val.starts_with?('/')
        val = val[1..]
        pos = pos.copy_with(start_pos: (pos.start_pos || 0) + 1)
      end
      if val.ends_with?('/')
        val = val[0...-1]
        pos = pos.copy_with(end_pos: (pos.end_pos || 0) - 1)
      end
      {val, pos}
    end

    private def self.parse_path(p : String, start : Int32) : GitUrlPath
      endswith_slash = p.ends_with?('/')

      org = nil
      org_pos = nil
      repo = nil
      repo_pos = nil
      path = nil
      path_pos = nil
      plen = p.size

      last_slash_pos = p.rindex('/', endswith_slash ? plen - 1 : plen)
      if last_slash_pos && last_slash_pos > start && last_slash_pos < plen
        org, org_pos = make(p, start, last_slash_pos - 1)
        repo, repo_pos = make(p, last_slash_pos, plen)
      else
        repo, repo_pos = make(p, start, plen)
      end

      path, path_pos = make(p, start, plen)

      if repo && repo_pos
        repo, repo_pos = trim_slash(repo, repo_pos)
      end
      if org && org_pos
        org, org_pos = trim_slash(org, org_pos)
      end

      # Remove trimming of leading slash from path
      GitUrlPath.new(
          org: org,
          org_pos: org_pos,
          repo: repo,
          repo_pos: repo_pos,
          path: p[start..], # Use the original path without trimming the leading slash
          path_pos: GitUrlPos.new(start_pos: start, end_pos: p.size - 1)
        )
    end

    private def self.parse_host(p : String, start : Int32) : GitUrlHost
      host = nil
      host_pos = nil
      port = nil
      port_pos = nil
      path_obj = GitUrlPath.new(org: nil, org_pos: nil, repo: nil, repo_pos: nil, path: nil, path_pos: nil)

      plen = p.size

      first_colon_pos = p.index(':', start)
      if first_colon_pos && first_colon_pos > start
        host, host_pos = make(p, start, first_colon_pos - 1)

        first_slash_pos = p.index('/', first_colon_pos + 1)
        if first_slash_pos && first_slash_pos > first_colon_pos + 1
          port, port_pos = make(p, first_colon_pos + 1, first_slash_pos - 1)
          path_obj = parse_path(p, first_slash_pos)
        else
          port, port_pos = make(p, first_colon_pos + 1, plen)
        end
      else
        first_slash_pos = p.index('/', start)
        if first_slash_pos && first_slash_pos > start
          host, host_pos = make(p, start, first_slash_pos - 1)
          path_obj = parse_path(p, first_slash_pos)
        else
          path_obj = parse_path(p, start)
        end
      end

      GitUrlHost.new(
        host: host,
        host_pos: host_pos,
        port: port,
        port_pos: port_pos,
        path_obj: path_obj
      )
    end

    private def self.parse_host_with_omit_ssh(p : String, start : Int32) : GitUrlHost
      host = nil
      host_pos = nil
      port = nil
      port_pos = nil
      path_obj = GitUrlPath.new(org: nil, org_pos: nil, repo: nil, repo_pos: nil, path: nil, path_pos: nil)

      plen = p.size

      first_colon_pos = p.index(':', start)
      if first_colon_pos && first_colon_pos > start
        host, host_pos = make(p, start, first_colon_pos - 1)
        path_obj = parse_path(p, first_colon_pos + 1)
      else
        path_obj = parse_path(p, start)
      end

      GitUrlHost.new(
        host: host,
        host_pos: host_pos,
        port: port,
        port_pos: port_pos,
        path_obj: path_obj
      )
    end

    private def self.parse_user(p : String, start : Int32, ssh_protocol_omitted : Bool = false) : GitUrlUser
      user = nil
      user_pos = nil
      password = nil
      password_pos = nil
      host_obj = GitUrlHost.new(host: nil, host_pos: nil, port: nil, port_pos: nil, path_obj: GitUrlPath.new(org: nil, org_pos: nil, repo: nil, repo_pos: nil, path: nil, path_pos: nil))

      plen = p.size

      host_start_pos = start

      first_at_pos = p.index('@', start)
      if first_at_pos
        first_colon_pos = p.index(':', start)
        if first_colon_pos && first_colon_pos < first_at_pos
          user, user_pos = make(p, start, first_colon_pos - 1)
          password, password_pos = make(p, first_colon_pos + 1, first_at_pos - 1)
        else
          user, user_pos = make(p, start, first_at_pos) # Use first_at_pos as the end position for the user
        end

        host_start_pos = first_at_pos + 1
      else
        host_start_pos = start
      end

      host_obj = ssh_protocol_omitted ? parse_host_with_omit_ssh(p, host_start_pos) : parse_host(p, host_start_pos)

      GitUrlUser.new(
        user: user,
        user_pos: user_pos,
        password: password,
        password_pos: password_pos,
        host_obj: host_obj
      )
    end
  end
end
