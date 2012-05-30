# coding: utf-8
module Shotcrawl
  class Textareas
    include Enumerable
    
    def initialize(textareas)
      @textareas = []
      
      textareas.each_with_index do |textarea, index|
        @textareas << Shotcrawl::Textarea.new(textarea, index)
      end
    end
    
    def each
      @textareas.each do |textarea|
        yield textarea
      end
    end
  end
  
  class Textarea
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser
    
    include Shotcrawl::Testable
    
    def initialize(textarea, index)
      @browser = textarea.browser
      @id      = textarea.id
      @name    = textarea.name
      @type    = textarea.type
      @value   = textarea.value
      @placeholder = textarea.placeholder
      @index   = index
    end
    
    def value=(arg)
      if @browser.textareas[@index].exists?
        @browser.textareas[@index].value = arg
        @value = arg
      
      else
        raise "Textareas not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end