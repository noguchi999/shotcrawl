# coding: utf-8
module Shotcrawl
  module Testcase
    module Option
      module Behavior

        def select_list_option_select
          result = OpenStruct.new
          result.action   = build_select_list_option_select_action
          result.expected = build_select_list_option_select_expected
          
          result
        end
        
        private
          def build_select_list_option_select_action
            Proc.new do |expected|
              self.select
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_select_list_option_select_expected
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