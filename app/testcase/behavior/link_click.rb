# coding: utf-8
module Shotcrawl
  module Testcase
    module Link
      module Behavior

        def link_click
          result = OpenStruct.new
          result.action   = build_link_click_action
          result.expected = build_link_click_expected
          
          result
        end
        
        private
          def build_link_click_action
            Proc.new do |expected|
              self.click

              if @target == '_blank'
                browser.goto @href
                suffix = " が表示されました."
              else
                suffix = " に遷移しました."
              end
              
              if browser.title.strip == expected.title.strip && browser.url.strip == expected.url.strip
                result = Shotcrawl::Testcase::Result.new(status: :success, message: "")
              else
                result = Shotcrawl::Testcase::Result.new(status: :error, message: %Q|Title: #{browser.title}, Url: #{browser.url}#{suffix}|)
              end
              
              result
            end
          end
          
          def build_link_click_expected
            Proc.new do 
              expected = Expected.new
              
              self.click
              begin
                if self.target == "_blank"
                  self.browser.goto self.href
                  expected.title = browser.title
                  expected.url   = browser.url
                else
                  expected.title = browser.title
                  expected.url   = browser.url
                end
                
                if expected.title.to_s[/error|エラー|404|not found/i]
                  expected.status = Status.new(:warning)
                else
                  expected.status = Status.new(:normal)
                end
                
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