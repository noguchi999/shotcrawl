# coding: utf-8
module Shotcrawl
  class Forms
    include Enumerable
    
    def initialize(forms, current_uri=nil)
      @forms = []
      
      forms.each_with_index do |form, index|
        if form.visible?
          @forms << Shotcrawl::Form.new(form, index: index, current_uri: current_uri)
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
    attr_reader :id, :name, :action, :buttons, :select_lists, :text_fields, :radios, :checkboxes, :file_fields, :textareas, :current_uri, :index, :browser
    
    include Shotcrawl::Testable 
    
    def initialize(form, options={})
      opts = {index: 0}.merge(options).symbolize_keys
      
      @browser      = form.browser
      @id           = form.id
      @name         = form.name
      @action       = form.action
      @buttons      = Shotcrawl::Buttons.new(form.buttons, opts[:current_uri])
      @select_lists = Shotcrawl::SelectLists.new form.select_lists
      @text_fields  = Shotcrawl::TextFields.new form.text_fields
      @radios       = Shotcrawl::Radios.new form.radios
      @checkboxes   = Shotcrawl::Checkboxes.new form.checkboxes
      @file_fields  = Shotcrawl::FileFields.new form.file_fields
      @textareas    = Shotcrawl::Textareas.new form.textareas
      @index        = index
    end
  end
end