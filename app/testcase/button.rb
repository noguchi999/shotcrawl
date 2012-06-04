# coding: utf-8
module Shotcrawl
  module Testcase
    module Button
      include Behavior
      
      def create_testcase
        TestCase.new(build_actions)
      end
      
      def test_unit
        build_test_unit
      end
      
      def default
        result = OpenStruct.new
        result.action   = build_default_action
        result.expected = build_default_expected
        
        result
      end
      
      private
        def build_actions
          actions = []
          Behavior.instance_methods.each_with_index do |method, index|
            result = self.__send__(method)
            actions << Action.new(index: index, name: method.to_sym, action: result.action, expected: result.expected)
          end
          
          actions
        end
        
        def build_test_unit
          _test_unit = OpenStruct.new
          _test_unit.element = self
          _test_unit.actions = {}
          
          Behavior.instance_methods.each do |method|
            result = self.__send__(method)
            
            _test_unit.actions.store(method.to_sym, result.action)
          end
          _test_unit
        end
        
        def build_default_action
          Proc.new do |expected|
            self.click
            self.browser.goto self.callback_uri.to_s
            
            Shotcrawl::Testcase::Result.new(status: :success, message: "")
          end
        end
        
        def build_default_expected
          Proc.new do 
            expected = Expected.new
            expected.status = Status.new(:normal)
            expected
          end
        end
    end
  end
end