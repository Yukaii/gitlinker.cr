require "option_parser"
require "./src/*"

module Gitlinker
  VERSION = "0.1.0"

  class CLI
    @file : String?
    @start_line : Int32?
    @end_line : Int32?

    def initialize
      parse_options
    end

    def parse_options
      OptionParser.parse do |parser|
        parser.banner = "Welcome to Gitlinker!"

        parser.on "-v", "--version", "Show version" do
          puts "Gitlinker version #{VERSION}"
          exit
        end

        parser.on "-h", "--help", "Show help" do
          puts parser
          exit
        end

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
    end

    def run
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
        puts "Invalid arguments. Please provide the required options."
        puts "Use --help for more information."
      end
    end

    private def output_url(url)
      puts url
    end
  end
end

Gitlinker::CLI.new.run
