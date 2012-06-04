# coding: utf-8
module Shotcrawl
  class Radios
    include Enumerable
    
    def initialize(radios, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @radios = []
      
      radios.each_with_index do |radio, index|
        @radios << Shotcrawl::Radio.new(radio, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
      end
    end
    
    def each
      @radios.each do |radio|
        yield radio
      end
    end
  end
  
  class Radio
    attr_reader :id, :type, :name, :value, :browser, :callback_uri, :current
    
    include Shotcrawl::Testable
    
    def initialize(radio, options={})
      opts = {index: 0, current: Proc.new {radio.browser}}.merge(options).symbolize_keys
      
      @browser  = radio.browser
      @id       = radio.id
      @type     = radio.type
      @name     = radio.name
      @value    = radio.value
      @disabled = radio.disabled?
      
      @current      = opts[:current]
      @callback_uri = opts[:callback_uri]
      @index        = opts[:index]
    end
    
    def disabled?
      @disabled
    end
    
    def click
      element = @current.call
      if element.radios[@index].exists?
        element.radios[@index].click
        
      else
        raise "Radio not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
end