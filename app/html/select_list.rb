# coding: utf-8
module Shotcrawl
  class SelectLists
    include Enumerable
    
    def initialize(select_lists, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @select_lists = []
      
      select_lists.each_with_index do |select_list, index|
        @select_lists << Shotcrawl::SelectList.new(select_list, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
      end
    end
    
    def each
      @select_lists.each do |select_list|
        yield select_list
      end
    end
  end
  
  class SelectList
    attr_reader :id, :name, :type, :value, :options, :selected_options, :index, :length, :browser, :callback_uri, :current
    
    include Shotcrawl::Testable
    
    def initialize(select_list, options={})
      opts = {index: 0, current: select_list.browser}.merge(options).symbolize_keys
    
      @browser = select_list.browser
      @id      = select_list.id
      @name    = select_list.name
      @type    = select_list.type
      @value   = select_list.value
      @options = Shotcrawl::Options.new(select_list, current: opts[:current], callback_uri: opts[:callback_uri])
      @selected_options = select_list.selected_options
      @autofocus  = select_list.autofocus?
      @disabled   = select_list.disabled?
      @required   = select_list.required?
      @length     = select_list.length
      
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
    
    def required?
      @required
    end
  end
  
  class Options
    include Enumerable
    
    def initialize(select_list, options={})
      opts = {current: nil, callback_uri: nil}.merge(options).symbolize_keys
      @optoins = []
      
      select_list.options.each_with_index do |option, index|
        @optoins << Shotcrawl::Option.new(option, select_list: select_list, index: index, current: opts[:current], callback_uri: opts[:callback_uri])
      end
    end
    
    def each
      @optoins.each do |option|
        yield option
      end
    end
  end
  
  class Option
    attr_reader :id, :name, :value, :type, :index, :browser
    
    include Shotcrawl::Testable
    
    def initialize(option, options={})
      opts = {index: 0, current: option.browser}.merge(options).symbolize_keys
      
      @browser = option.browser
      @id      = option.id
      @label   = option.label
      @value   = option.value
      
      @index             = opts[:index]
      @select_list_id    = opts[:select_list].id
      @select_list_name  = opts[:select_list].name
      @select_list_type  = opts[:select_list].type
      @select_list_value = opts[:select_list].value
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
        
      elsif select_list.option(label: @label).exists?
        select_list.option(label: @label,).select
        
      elsif select_list.option(value: @value).exists?
        select_list.option(value: @value).select
        
      elsif select_list.options[@index].exists?
        select_list.options[@index].select
        
      else
        raise "Option not found. Id: #{@id}, Name: #{@name}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
end