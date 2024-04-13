module Gitlinker
  module Configs
    DEFAULT_ROUTERS = {
      "browse" => {
        "^github\.com" => "https://github.com/{org}/{repo}/blob/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\#{lend}\" : \"\"}",
        "^gitlab\.com" => "https://gitlab.com/{org}/{repo}/blob/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\#{lend}\" : \"\"}",
        # Add more browse routes for other Git hosting providers
      },
      "blame" => {
        "^github\.com" => "https://github.com/{org}/{repo}/blame/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\#{lend}\" : \"\"}",
        "^gitlab\.com" => "https://gitlab.com/{org}/{repo}/blame/{rev}/{file}#L{lstart}{lend > lstart ? \"-L\#{lend}\" : \"\"}",
        # Add more blame routes for other Git hosting providers
      },
      # Add more router types (e.g., default_branch, current_branch) and their corresponding routes
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
