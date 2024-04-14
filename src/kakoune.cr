module Gitlinker
  module Kakoune
    extend self

    macro load_config
      {{ read_file("#{__DIR__}/kakoune/rc.kak") }}
    end

    CONFIG = load_config
  end
end
