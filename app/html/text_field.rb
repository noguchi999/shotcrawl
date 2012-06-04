# coding: utf-8
module Shotcrawl
  class TextFields
    include Enumerable
    
    def initialize(text_fields, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @text_fields = []
      
      text_fields.each_with_index do |text_field, index|
        @text_fields << Shotcrawl::TextField.new(text_field, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
      end
    end
    
    def each
      @text_fields.each do |text_field|
        yield text_field
      end
    end
  end
  
  class TextField
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser, :min, :max, :callback_uri, :current
    
    include Shotcrawl::Testable
    
    def initialize(text_field, options={})
      opts = {index: 0, current: Proc.new {text_field.browser}}.merge(options).symbolize_keys
      
      @browser      = text_field.browser
      @id           = text_field.id
      @name         = text_field.name
      @type         = text_field.type
      @value        = text_field.value
      @placeholder  = text_field.placeholder
      @autofocus    = text_field.autofocus?
      @disabled     = text_field.disabled?
      @read_only    = text_field.read_only?
      @required     = text_field.required?
      @min          = text_field.min
      @max          = text_field.max
      
      @current      = opts[:current]
      @callback_uri = opts[:callback_uri]
      @index        = opts[:index]
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
      element = @current.call
      if element.text_fields[@index].exists?
        element.text_fields[@index].value = arg
        @value = arg
      
      else
        raise "TextField not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end