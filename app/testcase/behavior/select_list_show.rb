# coding: utf-8
module Shotcrawl
  module Testcase
    module SelectList
      module Behavior

        def select_list_show
          result = OpenStruct.new
          result.action   = build_select_list_show_action
          result.expected = build_select_list_show_expected
          
          result
        end
        
        private
          def build_select_list_show_action
            Proc.new do |expected|
              self
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_select_list_show_expected
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