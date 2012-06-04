# coding: utf-8
module Shotcrawl
  module Testcase
    module Form
      include Behavior
      
      def create_testcases
        test_units = []
        
        #self.text_fields.each do |text_filed|
        #  test_units << text_filed.test_unit
        #end
        
        #self.select_lists.each do |select_list|
        #  select_list.options.each do |option|
        #    test_units << option.test_unit
        #  end
        #end
        
        #self.radios.each do |radio|
        #  test_units << radio.test_unit
        #end
        
        self.checkboxes.each do |checkbox|
          test_units << checkbox.test_unit
        end
        
        self.buttons.each do |button|
          test_units << button.test_unit
        end
        
        testcases = []
        test_units.each do |test_unit|
          _test_units = test_units.select{|u| u != test_unit}
          test_unit.actions.each do |key, value|
            testcases << TestCase.new(
              _test_units.inject([Action.new(id: test_unit.element.id, name: key.to_sym, action: value)]) do |actions, _test_unit|
                actions << Action.new(id: _test_unit.element.id, name: :default_action, action: _test_unit.element.default.action)
              end
            )
          end
        end
        
        #pp "testcases_log: #{testcases}"
        
        testcases
      end
    end
  end
end