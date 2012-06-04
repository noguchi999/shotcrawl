# coding: utf-8
module Shotcrawl
  class Buttons
    include Enumerable
    
    def initialize(buttons, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @buttons = []
      
      buttons.each_with_index do |button, index|
        if button.visible?
          @buttons << Shotcrawl::Button.new(button, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
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
    attr_reader :id, :type, :name, :value, :browser, :callback_uri, :current
    
    include Shotcrawl::Testable
    
    def initialize(button, options={})
      opts = {index: 0, current: Proc.new {button.browser}}.merge(options).symbolize_keys
      
      @browser  = button.browser
      @id       = button.id
      @type     = button.type
      @name     = button.name
      @value    = button.value
      @disabled = button.disabled?
      
      @current      = opts[:current]
      @callback_uri = opts[:callback_uri]
      @index        = opts[:index]
    end
    
    def disabled?
      @disabled
    end
    
    def click
      element = @current.call
      if element.buttons[@index].exists?
        element.buttons[@index].click
        
      else
        raise "Button not found. Id: #{@id} , Type: #{@type} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
end