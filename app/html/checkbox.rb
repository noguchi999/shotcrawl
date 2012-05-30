# coding: utf-8
module Shotcrawl
  class Checkboxes
    include Enumerable
    
    def initialize(checkboxes)
      @checkboxes = []
      
      checkboxes.each_with_index do |checkbox, index|
        @checkboxes << Shotcrawl::Checkbox.new(checkbox, index)
      end
    end
    
    def each
      @checkboxes.each do |checkbox|
        yield checkbox
      end
    end
  end
  
  class Checkbox
    attr_reader :id, :type, :name, :value, :browser
    
    include Shotcrawl::Testable
    
    def initialize(checkbox, index)
      @browser  = checkbox.browser
      @id       = checkbox.id
      @type     = checkbox.type
      @name     = checkbox.name
      @value    = checkbox.value
      @index    = index
      @disabled = checkbox.disabled?
    end
    
    def disabled?
      @disabled
    end
    
    def click
      if @browser.checkboxes[@index].exists?
        @browser.checkboxes[@index].click
        
      else
        raise "Checkbox not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
end