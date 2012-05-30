# coding: utf-8
module Shotcrawl
  module Testcase
    module Image
      module Behavior

        def image_click
          result = OpenStruct.new
          result.action   = build_image_click_action
          result.expected = build_image_click_expected
          
          result
        end
        
        private
          def build_image_click_action
            Proc.new do |expected|
              self.click
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_image_click_expected
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