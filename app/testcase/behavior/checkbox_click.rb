# coding: utf-8
module Shotcrawl
  module Testcase
    module Checkbox
      module Behavior

        def checkbox_click
          result = OpenStruct.new
          result.action   = build_checkbox_click_action
          result.expected = build_checkbox_click_expected
          
          result
        end
        
        private
          def build_checkbox_click_action
            Proc.new do |expected|
              self.click
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_checkbox_click_expected
            Proc.new do 
              expected = Expected.new
              expected.status = Status.new(:normal)
              expected
            end
          end
      end
    end
  end
end