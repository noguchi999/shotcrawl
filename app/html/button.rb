# coding: utf-8
module Shotcrawl
  class Buttons
    include Enumerable
    
    def initialize(buttons, current_uri=nil)
      @buttons = []
      
      buttons.each_with_index do |button, index|
        if button.visible?
          @buttons << Shotcrawl::Button.new(button, index: index, current_uri: current_uri)
        end
      end
    end
    
    def each
      @buttons.each do |button|
        yield button
      end
    end
  end
  
  class Button
    attr_reader :id, :type, :name, :value, :current_uri, :browser
    
    include Shotcrawl::Testable
    
    def initialize(button, options={})
      opts = {index: 0}.merge(options).symbolize_keys
      
      @browser  = button.browser
      @id       = button.id
      @type     = button.type
      @name     = button.name
      @value    = button.value
      @disabled = button.disabled?
      
      @current_uri = opts[:current_uri]
      @index       = opts[:index]
     
    end
    
    def disabled?
      @disabled
    end
    
    def click
      if @browser.buttons[@index].exists?
        @browser.buttons[@index].click
        
      else
        raise "Button not found. Id: #{@id} , Type: #{@type} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
end