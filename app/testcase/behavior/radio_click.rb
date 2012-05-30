# coding: utf-8
module Shotcrawl
  module Testcase
    module Radio
      module Behavior

        def radio_click
          result = OpenStruct.new
          result.action   = build_radio_click_action
          result.expected = build_radio_click_expected
          
          result
        end
        
        private
          def build_radio_click_action
            Proc.new do |expected|
              self.click
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_radio_click_expected
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