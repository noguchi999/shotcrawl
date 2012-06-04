# coding: utf-8
module Shotcrawl
  class Textareas
    include Enumerable
    
    def initialize(textareas, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @textareas = []
      
      textareas.each_with_index do |textarea, index|
        @textareas << Shotcrawl::Textarea.new(textarea, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
      end
    end
    
    def each
      @textareas.each do |textarea|
        yield textarea
      end
    end
  end
  
  class Textarea
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser, :callback_uri, :current
    
    include Shotcrawl::Testable
    
    def initialize(textarea, options={})
      opts = {index: 0, current: Proc.new {textarea.browser}}.merge(options).symbolize_keys
      
      @browser = textarea.browser
      @id      = textarea.id
      @name    = textarea.name
      @type    = textarea.type
      @value   = textarea.value
      @placeholder = textarea.placeholder
      
      @current      = opts[:current]
      @callback_uri = opts[:callback_uri]
      @index        = opts[:index]
    end
    
    def value=(arg)
      element = @current.call
      if element.textareas[@index].exists?
        element.textareas[@index].value = arg
        @value = arg
      
      else
        raise "Textareas not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end