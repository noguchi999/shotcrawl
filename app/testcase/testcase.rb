# coding: utf-8
module Shotcrawl
  module Testcase
    class TestCase
      include Enumerable
      attr_reader :actions
      
      def initialize(actions)
        @actions  = actions
        @expected = Expected.new
      end
      
      def do
        results = []
        @actions.each do |action|
          results << action.do(@expected)
        end
        results
      end
      
      def each
        @actions.each do |action|
          yield action
        end
      end
    end
    
    class Action
      attr_reader :id, :index, :name, :action
      
      def initialize(options={})
        opts = options.symbolize_keys
        
        @id       = opts[:id]
        @index    = opts[:index]
        @name     = opts[:name]
        @action   = opts[:action]
      end
      
      def do(expected)
        action.call expected
      end
    end
  end
end