# coding: utf-8
module Shotcrawl
  class TextFields
    include Enumerable
    
    def initialize(text_fields)
      @text_fields = []
      
      text_fields.each_with_index do |text_field, index|
        @text_fields << Shotcrawl::TextField.new(text_field, index)
      end
    end
    
    def each
      @text_fields.each do |text_field|
        yield text_field
      end
    end
  end
  
  class TextField
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser, :min, :max
    
    include Shotcrawl::Testable
    
    def initialize(text_field, index)
      @browser = text_field.browser
      @id      = text_field.id
      @name    = text_field.name
      @type    = text_field.type
      @value   = text_field.value
      @placeholder = text_field.placeholder
      @index      = index
      @autofocus  = text_field.autofocus?
      @disabled   = text_field.disabled?
      @read_only  = text_field.read_only?
      @required   = text_field.required?
      @min        = text_field.min
      @max        = text_field.max
    end
    
    def autofocus?
      @autofocus
    end
    
    def disabled?
      @disabled
    end
    
    def read_only?
      @read_only
    end 
    
    def required?
      @required
    end
    
    def value=(arg)
      if @browser.text_fields[@index].exists?
        @browser.text_fields[@index].value = arg
        @value = arg
      
      else
        raise "TextField not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end