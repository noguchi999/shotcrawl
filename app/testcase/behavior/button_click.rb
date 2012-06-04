# coding: utf-8
module Shotcrawl
  module Testcase
    module Button
      module Behavior

        def button_click
          result = OpenStruct.new
          result.action   = build_button_click_action
          result.expected = build_button_click_expected
          
          result
        end
        
        private
          def build_button_click_action
            Proc.new do |expected|
              self.click
              begin
                if browser.title.strip == expected.title.strip && browser.url.strip == expected.url.strip
                  result = Shotcrawl::Testcase::Result.new(status: :success, message: "")
                else
                  result = Shotcrawl::Testcase::Result.new(status: :error, message: %Q|Title: #{browser.title}, Url: #{browser.url}|)
                end
                
                self.browser.goto self.callback_uri.to_s
                
              rescue Selenium::WebDriver::Error::UnhandledAlertError
                browser.driver.switch_to.alert.dismiss
                retry
              end
              
              result
            end
          end
          
          def build_button_click_expected
            Proc.new do 
              expected = Expected.new
              
              self.click
              begin
                expected.title  = browser.title
                expected.url    = browser.url
                expected.status = Status.new(:normal)
                
                self.browser.goto self.callback_uri.to_s
                
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