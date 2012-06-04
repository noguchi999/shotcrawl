# coding: utf-8
module Shotcrawl
  class Checkboxes
    include Enumerable
    
    def initialize(checkboxes, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @checkboxes = []
      
      checkboxes.each_with_index do |checkbox, index|
        @checkboxes << Shotcrawl::Checkbox.new(checkbox, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
      end
    end
    
    def each
      @checkboxes.each do |checkbox|
        yield checkbox
      end
    end
  end
  
  class Checkbox
    attr_reader :id, :type, :name, :value, :browser, :callback_uri, :current
    
    include Shotcrawl::Testable
    
    def initialize(checkbox, options={})
      opts = {index: 0, current: Proc.new {checkbox.browser}}.merge(options).symbolize_keys
      
      @browser  = checkbox.browser
      @id       = checkbox.id
      @type     = checkbox.type
      @name     = checkbox.name
      @value    = checkbox.value
      @disabled = checkbox.disabled?
      
      @current      = opts[:current]
      @callback_uri = opts[:callback_uri]
      @index        = opts[:index]
    end
    
    def disabled?
      @disabled
    end
    
    def click
      element = @current.call
      if element.checkboxes[@index].exists?
        element.checkboxes[@index].click
        
      else
        raise "Checkbox not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
    
    def clear
      element = @current.call
      if element.checkboxes[@index].exists?
        element.checkboxes[@index].clear
        
      else
        raise "Checkbox not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
end