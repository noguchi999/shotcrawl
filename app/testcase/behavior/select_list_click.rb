# coding: utf-8
module Shotcrawl
  module Testcase
    module SelectList
      module Behavior

        def select_list_click
          result = OpenStruct.new
          result.action   = build_select_list_click_action
          result.expected = build_select_list_click_expected
          
          result
        end
        
        private
          def build_select_list_click_action
            Proc.new do |expected|
              self.click
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_select_list_click_expected
            Proc.new do 
              expected = Expected.new
              expected.status = Status.new(:normal)
              expected
            end
          end
      end
    end
    
    module Option
      module Behavior

        def option_click
          result = OpenStruct.new
          result.action   = build_option_click_click_action
          result.expected = build_option_click_click_expected
          
          result
        end
        
        private
          def build_option_click_click_action
            Proc.new do |expected|
              self.click
              Shotcrawl::Testcase::Result.new(status: :success, message: "")
            end
          end
          
          def build_option_click_click_expected
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