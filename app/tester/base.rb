require 'active_support/core_ext'
require File.expand_path('links')

module Shotcrawl
  module Tester
  
    class Base
      COMMANDS = {}
      
      class << self
        def command(command, type)
          COMMANDS[command] = type
          COMMANDS.symbolize_keys
        end
      end
      
      def execute(command)
        raw_execute(command)
      end
      
      private
        def raw_execute(command)
          type = COMMANDS[command] || raise(ArgumentError, "unknown command: #{command.inspect}")
          
          type.__send__ command
        end
    end
  end
end