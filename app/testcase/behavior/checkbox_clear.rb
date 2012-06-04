# coding: utf-8
module Shotcrawl
  module Testcase
    module Checkbox
      module Behavior

        def checkbox_clear
          result = OpenStruct.new
          result.action   = build_checkbox_clear_action
          result.expected = build_checkbox_clear_expected
          
          result
        end
        
        private
          def build_checkbox_clear_action
            Proc.new do |expected|
              self.clear
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_checkbox_clear_expected
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