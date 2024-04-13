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
      case key
      when "repo"
        value.as(String).ends_with?(".git") ? value.as(String)[0..-5] : value
      when "file"
        value.as(String).ends_with?(/.md/i) ? "#{value}?plain=1" : value
      else
        value
      end
    end

    private def self.evaluate_conditionals(url, linker)
      url.gsub(/\{(.*?)\?\s*(.*?)\s*:\s*(.*?)\}/) do |match|
        condition, true_value, false_value = $1, $2, $3
        result = if evaluate_condition(condition, linker)
                   substitute_placeholders(true_value, linker)
                 else
                   substitute_placeholders(false_value, linker)
                 end

        # unwrap string variable
        result.match(/^"(.*)"$/) ? $1 : result
      end
    end

    private def self.evaluate_condition(condition, linker)
      # Implement a simple condition evaluator
      # Example: "lend > lstart"
      operator = condition[/(?:>|<|==)/]
      left, right = condition.split(operator).map(&.strip)

      left_value = linker.resolve_key(left)
      right_value = linker.resolve_key(right)
      case operator
      when ">"
        compare(left_value, right_value) { |a, b| a > b }
      when "<"
        compare(left_value, right_value) { |a, b| a < b }
      when "=="
        left_value == right_value
      else
        false
      end
    end

    private def self.compare(left, right)
      if left.is_a?(Int32) && right.is_a?(Int32)
        yield left, right
      else
        false
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
