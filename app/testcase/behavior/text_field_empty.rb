# coding: utf-8
module Shotcrawl
  module Testcase
    module TextField
      module Behavior

        def text_field_empty
          result = OpenStruct.new
          result.action   = build_text_field_empty_action
          result.expected = build_text_field_empty_expected
          
          result
        end
        
        private
          def build_text_field_empty_action
            Proc.new do |expected|
              unless self.disabled? && self.read_only?
                unless self.required?
                  input_text = nil
                else
                  input_text = "required"
                end
                self.value = input_text
              end
              
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_text_field_empty_expected
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