module Gitlinker
  module Routers
    def self.generate_url(linker : Linker, router_type = "browse")
      routes = Configs.routers[router_type]?
      return nil unless routes

      routes.each do |pattern, route|
        if linker.host.matches?(Regex.new(pattern))
          url = route.gsub(/\{(\w+)\}/) do |match|
            key = match[1..-2]
            value = preprocess_value(key, linker.resolve_key(key))
            value.to_s
          end

          url = evaluate_conditionals(url, linker)

          return url
        end
      end

      nil
    end

    private def self.preprocess_value(key, value)
      return value unless value.is_a?(String)

      case key
      when "repo"
        value.ends_with?(".git") ? value[0..-5] : value
      else
        value
      end
    end

    private def self.evaluate_conditionals(url, linker)
      # Match ternary conditionals like: {lend > lstart ? "value" : ""}
      url.gsub(/\{([^?}]+)\?\s*("(?:[^"\\]|\\.)*"|[^:}]+)\s*:\s*("(?:[^"\\]|\\.)*"|[^}]+)\}/) do |match|
        condition, true_value, false_value = $1, $2, $3
        result = if evaluate_condition(condition, linker)
                   substitute_placeholders(true_value, linker)
                 else
                   substitute_placeholders(false_value, linker)
                 end

        # unwrap string literal quotes
        if result.starts_with?('"') && result.ends_with?('"')
          result[1..-2]
        else
          result
        end
      end
    end

    private def self.evaluate_condition(condition, linker)
      operator = condition[/(?:>|<|==)/]
      return false unless operator

      left, right = condition.split(operator).map(&.strip)
      left_value = linker.resolve_key(left)
      right_value = linker.resolve_key(right)

      return false unless left_value.is_a?(Int32) && right_value.is_a?(Int32)

      case operator
      when ">" then left_value > right_value
      when "<" then left_value < right_value
      when "==" then left_value == right_value
      else false
      end
    end

    private def self.substitute_placeholders(value, linker)
      value.gsub(/\{(\w+)\}/) do |match|
        key = match[1..-2]
        preprocess_value(key, linker.resolve_key(key)).to_s
      end
    end
  end
end
