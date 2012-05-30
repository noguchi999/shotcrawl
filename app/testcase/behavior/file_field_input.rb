# coding: utf-8
module Shotcrawl
  module Testcase
    module FileField
      module Behavior

        def file_field_input
          result = OpenStruct.new
          result.action   = build_file_field_input_action
          result.expected = build_file_field_input_expected
          
          result
        end
        
        private
          def build_file_field_input_action
            Proc.new do |expected|
              unless self.disabled? && self.read_only?
                self.value = create_text(self.min, self.max)
              end
              
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def create_text(min, max)
            min ||= 0
            max ||= 1024
            
            (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ("あ".."ん").to_a + ("!".."/").to_a).shuffle[min..max].join
          end
          
          def build_file_field_input_expected
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