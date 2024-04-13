module Gitlinker
  module Configs
    DEFAULT_ROUTERS = {
      "browse" => {
        "^github\.com" => "https://github.com/{org}/{repo}/blob/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^gitlab\.com" => "https://gitlab.com/{org}/{repo}/blob/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^bitbucket\.org" => "https://bitbucket.org/{org}/{repo}/src/{rev}/{file}#lines-{lstart}{lend > lstart ? \":\{lend}\" : \"\"}",
        "^codeberg\.org" => "https://codeberg.org/{org}/{repo}/src/commit/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
      },
      "blame" => {
        "^github\.com" => "https://github.com/{org}/{repo}/blame/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^gitlab\.com" => "https://gitlab.com/{org}/{repo}/blame/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^bitbucket\.org" => "https://bitbucket.org/{org}/{repo}/annotate/{rev}/{file}#lines-{lstart}{lend > lstart ? \":\{lend}\" : \"\"}",
        "^codeberg\.org" => "https://codeberg.org/{org}/{repo}/blame/commit/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
      },
      "default_branch" => {
        "^github\.com" => "https://github.com/{org}/{repo}/blob/{default_branch}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^gitlab\.com" => "https://gitlab.com/{org}/{repo}/blob/{default_branch}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^bitbucket\.org" => "https://bitbucket.org/{org}/{repo}/src/{default_branch}/{file}#lines-{lstart}{lend > lstart ? \":\{lend}\" : \"\"}",
        "^codeberg\.org" => "https://codeberg.org/{org}/{repo}/src/branch/{default_branch}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
      },
      "current_branch" => {
        "^github\.com" => "https://github.com/{org}/{repo}/blob/{current_branch}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^gitlab\.com" => "https://gitlab.com/{org}/{repo}/blob/{current_branch}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
        "^bitbucket\.org" => "https://bitbucket.org/{org}/{repo}/src/{current_branch}/{file}#lines-{lstart}{lend > lstart ? \":\{lend}\" : \"\"}",
        "^codeberg\.org" => "https://codeberg.org/{org}/{repo}/src/branch/{current_branch}/{file}#L{lstart}{lend > lstart ? \"-L\{lend}\" : \"\"}",
      },
    }

    @@routers = DEFAULT_ROUTERS

    def self.setup(user_routers = nil)
      if user_routers
        @@routers = merge_routers(user_routers)
      end
    end

    def self.routers
      @@routers
    end

    private def self.merge_routers(user_routers)
      result = {} of String => Hash(String, String)

      DEFAULT_ROUTERS.each do |router_type, default_routes|
        result[router_type] = default_routes.dup
      end

      user_routers.each do |router_type, user_routes|
        if result[router_type]?
          user_routes.each do |pattern, route|
            result[router_type][pattern] = route
          end
        else
          result[router_type] = user_routes
        end
      end

      result
    end
  end
end
