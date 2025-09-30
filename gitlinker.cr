require "option_parser"
require "./src/*"

module Gitlinker
  VERSION = "0.1.0"

  class CLI
    @file : String?
    @start_line : Int32?
    @end_line : Int32?
    @command = ""
    @parser : OptionParser

    def initialize
      @parser = parse_options
    end

    def parse_options
      OptionParser.parse do |parser|
          parser.banner = <<-BANNER
        Gitlinker is a command-line tool that generates URLs for specific lines of code in a Git repository hosted on various platforms like GitHub, GitLab, Bitbucket, and more.

        Usage:
          gitlinker command [options]

        Options:
        BANNER

        parser.on "-v", "--version", "Show version" do
          puts "Gitlinker version #{VERSION}"
          exit
        end

        parser.on "-h", "--help", "Show help" do
          puts parser
          exit
        end

        parser.on "help", "Show help" do
          puts parser
          exit
        end

        parser.on "run", "Run gitlinker" do
          @command = :run

          parser.banner = <<-BANNER
          Usage:
            gitlinker run [options]

          Options:
          BANNER

          parser.on "-f FILE", "--file=FILE", "Specify the file path" do |file|
            @file = file
          end

          parser.on "-s LINE", "--start-line=LINE", "Specify the start line number" do |line|
            @start_line = line.to_i
          end

          parser.on "-e LINE", "--end-line=LINE", "Specify the end line number" do |line|
            @end_line = line.to_i
          end
        end


        parser.on "init", "Print rc" do
          @command = :init

          parser.banner = <<-BANNER
          Usage:
            gitlinker init [options]

          Options:
          BANNER

          parser.on("kakoune", "Print Kakoune definitions") do
            @command = :init_kakoune
          end

          parser.on("neovim", "Print Neovim Lua plugin") do
            @command = :init_neovim
          end
        end
      end
    end

    def run
      case @command
      when :run
        if file = @file
          linker = Linker.make(file)
          if linker
            linker.lstart = @start_line
            linker.lend = @end_line
            url = Routers.generate_url(linker)
            output_url(url)
          else
            puts "Failed to create linker object."
          end
        else
          @parser.parse(["run", "--help"])
        end
      when :init
        @parser.parse(["init", "--help"])
      when :init_kakoune
        puts Kakoune::CONFIG
      when :init_neovim
        puts Neovim::CONFIG
      when ""
        puts @parser
      end
    end

    private def output_url(url)
      puts url
    end
  end
end

Gitlinker::CLI.new.run
