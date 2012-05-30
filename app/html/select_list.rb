# coding: utf-8
module Shotcrawl
  class SelectLists
    include Enumerable
    
    def initialize(select_lists)
      @select_lists = []
      
      select_lists.each_with_index do |select_list, index|
        @select_lists << Shotcrawl::SelectList.new(select_list, index)
      end
    end
    
    def each
      @select_lists.each do |select_list|
        yield select_list
      end
    end
  end
  
  class SelectList
    attr_reader :id, :name, :type, :value, :options, :selected_options, :index, :browser, :length
    
    include Shotcrawl::Testable
    
    def initialize(select_list, index)
      @browser = select_list.browser
      @id      = select_list.id
      @name    = select_list.name
      @type    = select_list.type
      @value   = select_list.value
      @options = Shotcrawl::Options.new(select_list)
      @selected_options = select_list.selected_options
      @index      = index
      @autofocus  = select_list.autofocus?
      @disabled   = select_list.disabled?
      @required   = select_list.required?
      @length     = select_list.length
    end
    
    def autofocus?
      @autofocus
    end
    
    def disabled?
      @disabled
    end
    
    def required?
      @required
    end
    
    def option(selector={})
      selector = selector.symbolize_keys
    
      if @browser.select_list.options[@index].exists?
        @browser.select_list.options[@index].select
        
      else
        raise "Option not found. #{selector.to_s}"
      end
    end
  end
  
  class Options
    include Enumerable
    
    def initialize(select_list)
      @optoins = []
      
      select_list.options.each_with_index do |option, index|
        @optoins << Shotcrawl::Option.new(option, index, select_list)
      end
    end
    
    def each
      @optoins.each do |option|
        yield option
      end
    end
  end
  
  class Option
    attr_reader :id, :name, :value, :index, :browser
    
    include Shotcrawl::Testable
    
    def initialize(option, index, select_list)
      @browser = option.browser
      @id      = option.id
      @label   = option.label
      @value   = option.value
      @index   = index
      @select_list_id    = select_list.id
      @select_list_name  = select_list.name
      @select_list_type  = select_list.type
      @select_list_value = select_list.value
    end
    
    def select
      if @browser.select_list(id: @select_list_id).exists?
        select_list = @browser.select_list(id: @select_list_id)
        
      elsif @browser.select_list(name: @select_list_name, type: @select_list_type).exists?
        select_list = @browser.select_list(name: @select_list_name, type: @select_list_type)
        
      elsif @browser.select_list(value: @value, type: @select_list_type).exists?
        select_list = @browser.select_list(value: @value, type: @select_list_type)
        
      else
        raise "SelectList not found. Id: #{@select_list_id}, Name: #{@select_list_name}, Type: #{@select_list_type}, Value: #{@select_list_value}"
      end
      
      if select_list.option(id: @id).exists?
        select_list.option(id: @id).select
        
      elsif select_list.option(label: @label, type: @type).exists?
        select_list.option(label: @label, type: @type).select
        
      elsif select_list.option(value: @value, type: @type).exists?
        select_list.option(value: @value, type: @type).select
        
      elsif select_list.options[@index].exists?
        select_list.options[@index].select
        
      else
        raise "Option not found. Id: #{@id}, Name: #{@name}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end