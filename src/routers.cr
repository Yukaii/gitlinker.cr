module Gitlinker
  module Routers
    def self.generate_url(linker : Linker, router_type = "browse")
      routes = Configs.routers[router_type]?
      return nil unless routes

      routes.each do |pattern, route|
        if linker.host.matches?(Regex.new(pattern))
          url = route.gsub(/{(\w+)}/) do |match|
            case match
            when "{ORG}"
              linker.org || ""
            when "{REPO}"
              linker.repo
            when "{REV}"
              linker.rev
            when "{FILE}"
              linker.file
            when "{LSTART}"
              linker.lstart ? "#L#{linker.lstart}" : ""
            when "{LEND}"
              if linker.lend && ((linker.lend || 0) > (linker.lstart || 0))
                "-L#{linker.lend}"
              else
                ""
              end
            else
              ""
            end
          end
          return url
        end
      end

      nil
    end
  end
end
