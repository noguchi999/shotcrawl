# coding: utf-8
module Shotcrawl
  module Testcase
    module Image
      include Behavior
      
      def create_testcase
        TestCase.new(build_actions)
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
    end
  end
end