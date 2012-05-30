# coding: utf-8
module Shotcrawl
  class Radios
    include Enumerable
    
    def initialize(radios)
      @radios = []
      
      radios.each_with_index do |radio, index|
        @radios << Shotcrawl::Radio.new(radio, index)
      end
    end
    
    def each
      @radios.each do |radio|
        yield radio
      end
    end
  end
  
  class Radio
    attr_reader :id, :type, :name, :value, :browser
    
    include Shotcrawl::Testable
    
    def initialize(radio, index)
      @browser  = radio.browser
      @id       = radio.id
      @type     = radio.type
      @name     = radio.name
      @value    = radio.value
      @index    = index
      @disabled = radio.disabled?
    end
    
    def disabled?
      @disabled
    end
    
    def click
      if @browser.radios[@index].exists?
        @browser.radios[@index].click
        
      else
        raise "Radio not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
end