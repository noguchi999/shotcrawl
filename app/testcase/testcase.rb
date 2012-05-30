# coding: utf-8
module Shotcrawl
  module Testcase
    class TestCase
      include Enumerable
      
      def initialize(actions)
        @actions  = actions
      end
      
      def do
        results = []
        @actions.each do |action|
          results << action.do
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
      attr_reader :index, :name, :action, :expected
      
      def initialize(options={})
        opts = options.symbolize_keys
        
        @index    =  opts[:index]
        @name     =  opts[:name]
        @action   =  opts[:action]
        @expected =  opts[:expected]
      end
      
      def do
        action.call expected.call
      end
    end
  end
end