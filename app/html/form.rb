# coding: utf-8
module Shotcrawl
  class Forms
    include Enumerable
    
    def initialize(forms, callback_uri=nil)
      @forms = []
      
      forms.each_with_index do |form, index|
        if form.visible?
          @forms << Shotcrawl::Form.new(form, index: index, callback_uri: callback_uri)
        end
      end
    end
    
    def each
      @forms.each do |form|
        yield form
      end
    end
  end
  
  class Form
    attr_reader :id, :name, :action, :buttons, :select_lists, :text_fields, :radios, :checkboxes, :file_fields, :textareas, :callback_uri, :index, :browser
    
    include Shotcrawl::Testable 
    
    def initialize(form, options={})
      opts = {index: 0}.merge(options).symbolize_keys
      current = Proc.new {@browser.forms[opts[:index]]}
      
      @browser      = form.browser
      @index        = opts[:index]
      @id           = form.id
      @name         = form.name
      @action       = form.action
      @buttons      = Shotcrawl::Buttons.new(form.buttons, callback_uri: opts[:callback_uri], current: current)
      @select_lists = Shotcrawl::SelectLists.new(form.select_lists, callback_uri: opts[:callback_uri], current: current)
      @text_fields  = Shotcrawl::TextFields.new(form.text_fields, callback_uri: opts[:callback_uri], current: current)
      @radios       = Shotcrawl::Radios.new(form.radios, callback_uri: opts[:callback_uri], current: current)
      @checkboxes   = Shotcrawl::Checkboxes.new(form.checkboxes, callback_uri: opts[:callback_uri], current: current)
      @file_fields  = Shotcrawl::FileFields.new(form.file_fields, callback_uri: opts[:callback_uri], current: current)
      @textareas    = Shotcrawl::Textareas.new(form.textareas, callback_uri: opts[:callback_uri], current: current)
    end
  end
end