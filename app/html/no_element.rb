# coding: utf-8
module Shotcrawl
  class NoElement
    attr_reader :browser
    
    def initialize(browser)
      @browser = browser
    end
    
    def click
      @browser.goto "about:blank"
    end
    
    def test(*args)
      {status: :error, message: "指定の要素は存在しません."}
    end
  end
end