require "option_parser"
require "uri"
require "./src/*"

module Gitlinker

  class CLI
    @file : String?
    @line : Int32?
    @column : Int32?

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

        parser.on "-l LINE", "--line=LINE", "Specify the line number" do |line|
          @line = line.to_i
        end

        parser.on "-c COLUMN", "--column=COLUMN", "Specify the column number" do |column|
          @column = column.to_i
        end
      end
    end

    def run
      if file = @file
        linker = Linker.make(file)
        if linker
          linker.lstart = @line
          linker.lend = @line
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

    private def generate_url(file, line, column)
      Gitlinker.generate_url(file, line, column)
    end

    private def output_url(url)
      puts url
    end
  end
end

Gitlinker::CLI.new.run
