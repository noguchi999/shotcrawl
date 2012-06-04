# coding: utf-8
module Shotcrawl
  module Testcase
    module Textarea
      module Behavior

        def textarea_input
          result = OpenStruct.new
          result.action   = build_textarea_input_action
          result.expected = build_textarea_input_expected
          
          result
        end
        
        private
          def build_textarea_input_action
            Proc.new do |expected|
              unless self.disabled? && self.read_only?
                input_text = fake_text_value(min: self.min, max: self.max)
                self.value = input_text
              end
              
              if self.value == input_text
                result = Result.new(status: :success, message: "")
              else
                result = Result.new(status: :error, message: %Q|Id: #{self.id}, Value: #{self.value}|)
              end
              
              result
            end
          end
          
          def build_textarea_input_expected
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