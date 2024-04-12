require "option_parser"
require "uri"

module Gitlinker
  VERSION = "1.0.0"

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
      if @file
        url = generate_url(@file, @line, @column)
        output_url(url)
      else
        puts "Invalid arguments. Please provide the required options."
        puts "Use --help for more information."
      end
    end

    private def generate_url(file, line, column)
      # Generate the URL based on the provided file, line, and column
      # The implementation logic for handling branch information and constructing the URL
      # should be handled within the Gitlinker module.
      # You can use the Gitlinker module's methods to generate the URL.
      # Example: Gitlinker.generate_url(file, line, column)
    end

    private def output_url(url)
      puts url
    end
  end
end

Gitlinker::CLI.new.run
