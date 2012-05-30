# coding: utf-8
module Shotcrawl
  class FileFields
    include Enumerable
    
    def initialize(file_fields)
      @file_fields = []
      
      file_fields.each_with_index do |file_field, index|
        @file_fields << Shotcrawl::FileField.new(file_field, index)
      end
    end
    
    def each
      @file_fields.each do |file_field|
        yield file_field
      end
    end
  end
  
  class FileField
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser, :min, :max
    
    include Shotcrawl::Testable
    
    def initialize(file_field, index)
      @browser = file_field.browser
      @id      = file_field.id
      @name    = file_field.name
      @type    = file_field.type
      @value   = file_field.value
      @placeholder = file_field.placeholder
      @index      = index
      @autofocus  = file_field.autofocus?
      @disabled   = file_field.disabled?
      @read_only  = file_field.read_only?
      @required   = file_field.required?
      @min        = file_field.min
      @max        = file_field.max
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
    
    def set(arg)
      if @browser.file_fields[@index].exists?
        @browser.file_fields[@index].set arg
        @value = arg
      
      else
        raise "FileField not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end