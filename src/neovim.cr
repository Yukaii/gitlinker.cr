module Gitlinker
  module Neovim
    extend self

    macro load_config
      {{ read_file("#{__DIR__}/neovim/init.lua") }}
    end

    CONFIG = load_config
  end
end