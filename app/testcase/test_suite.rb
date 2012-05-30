# coding: utf-8
module Shotcrawl
  module TestSuite
      
    def testcases
      @testcases ||= TestCases.new
    end
    
    def build_testcases
      yield testcases
      
      testcases
    end
    
    def test_run(test_no)
      testcase.each do |action|
        puts "#{test_no} : #{action.do.status}"
      end
      #puts testcases.find(test_no).do([expected]).first.status
    end
    
    def test_run_all
      results = []
      testcases.each do |testcase|
        results << testcase.do
      end
      results
    end
  
    class TestCases
      attr_accessor :test_no
      
      include Enumerable
      
      def initialize
        @testcases = {}
        @test_no   = Shotcrawl::Testcase::Number.new
      end
      
      def add(testcase)
        @testcases.store(@test_no.next, testcase)
      end
      
      def <<(testcase)
        add testcase
      end
      
      def find(test_no)
        @testcases[test_no] || raise(RuntimeError, "TestNo: #{test_no} is not found.")
      end
      
      def each
        @testcases.each_value do |testcase|
          yield testcase
        end
      end
    end
  end
end