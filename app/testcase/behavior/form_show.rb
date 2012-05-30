# coding: utf-8
module Shotcrawl
  module Testcase
    module Form
      module Behavior

        def form_show
          result = OpenStruct.new
          result.action   = build_form_show_action
          result.expected = build_form_show_expected
          
          result
        end
        
        private
          def build_form_show_action
            Proc.new do |expected|
              self.click
              
              if browser.title.strip == expected.title.strip && browser.url.strip == expected.url.strip
                result = Shotcrawl::Testcase::Result.new(status: :success, message: "")
              else
                result = Shotcrawl::Testcase::Result.new(status: :error, message: %Q|Title: #{browser.title}, Url: #{browser.url}|)
              end
              
              result
            end
          end
          
          def build_form_show_expected
            Proc.new do 
              expected = Expected.new
              
              self.click
              begin
                expected.title = browser.title
                expected.url   = browser.url
                
                self.browser.goto self.current_uri.to_s
                
              rescue Selenium::WebDriver::Error::UnhandledAlertError
                browser.driver.switch_to.alert.dismiss
                retry
              end
              
              expected
            end
          end
      end
    end
  end
end