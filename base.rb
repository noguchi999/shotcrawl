# coding: utf-8
require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'active_support/core_ext'
require 'yaml'
require File.expand_path('lib/weblinks/weblinks')
require 'logger'

$logger = Logger.new(File.expand_path("log/#{File.basename(__FILE__, '.rb')}.log"))

module Shotcrawl
  class Base
    attr_reader :browser, :configuration
    
    def initialize(options={})
      opts = {config_file: "#{File.expand_path('config/configuration.yml')}", env: :development}.merge(options.symbolize_keys)
      
      @configuration ||= YAML.load_file(opts[:config_file])[opts[:env].to_sym]
      @browser = Watir::Browser.new @configuration[:driver], @configuration[:options]
    end
    
    def analyze(url)
      @browser.goto url
      current_url = @browser.url
      
      $logger.debug @browser.text
      
      @browser.driver.save_screenshot("images/test.png")
      
      sc_links = Shotcrawl::Links.new(@browser.links)
      sc_links.each do |sc_link|
        $logger.debug "Links: #{sc_link.href} : #{sc_link.text} : #{sc_link.image_src}"
        sc_link.click
        begin
          @browser.goto current_url
        rescue Selenium::WebDriver::Error::UnhandledAlertError
          @browser.driver.switch_to.alert.dismiss
          @browser.goto current_url
        end
      end

      sc_buttons = Shotcrawl::Buttons.new(@browser.buttons)
      sc_buttons.each do |sc_button|
        $logger.debug "Buttons: #{sc_button.id} : #{sc_button.name} : #{sc_button.type} : #{sc_button.value}"
        sc_button.click
        begin
          @browser.goto current_url
        rescue Selenium::WebDriver::Error::UnhandledAlertError
          @browser.driver.switch_to.alert.dismiss
          @browser.goto current_url
        end
      end
      
      sc_select_lists = Shotcrawl::SelectLists.new(@browser.select_lists)
      sc_select_lists.each do |sc_select_list|
        sc_select_list.options.each do |option|
          $logger.debug "SelectList: #{option.id} : #{option.name} : #{option.value}"
        end
      end
      
      sc_text_fields = Shotcrawl::TextFields.new(@browser.text_fields)
      sc_text_fields.each do |sc_text_field|
        sc_text_field.value = "piyopiyo"
        $logger.debug "TextField: #{sc_text_field.id} : #{sc_text_field.name} : #{sc_text_field.type} : #{sc_text_field.placeholder} : #{sc_text_field.value}"
      end
      
      sc_textareas = Shotcrawl::Textareas.new(@browser.textareas)
      sc_textareas.each do |sc_textarea|
        sc_textarea.value = "fugafuga"
        $logger.debug "TextArea: #{sc_textarea.id} : #{sc_textarea.name} : #{sc_textarea.type} : #{sc_textarea.placeholder} : #{sc_textarea.value}"
      end
      
      @browser.radios.each do |radio|
        $logger.debug "Radio: #{radio}"
      end
      
      sc_file_fields = Shotcrawl::FileFields.new(@browser.file_fields)
      sc_file_fields.each do |sc_file_field|
        sc_file_field.set "C:/my_work/野口修_週間報告書_2012年度.xls"
        $logger.debug "TextArea: #{sc_file_field.id} : #{sc_file_field.name} : #{sc_file_field.type} : #{sc_file_field.placeholder} : #{sc_file_field.value}"
      end
    end
  end
  
  class Links
    include Enumerable
    
    def initialize(links)
      @links = []
      
      links.each_with_index do |link, index|
        if link.visible? && (link.href != link.browser.url)
          @links << Shotcrawl::Link.new(link, index)
        end
      end
    end
    
    def each
      @links.each do |link|
        yield link
      end
    end
  end
  
  class Link
    attr_reader :href, :text, :image_src, :browser
    
    def initialize(link, index)
      @browser   = link.browser
      @href      = link.href
      @text      = link.text
      @image_src = link.image.src if link.image.exists?
      @index = index
    end
    
    def click
      if @browser.links[@index].exists?
        @browser.links[@index].click
      
      elsif @browser.link(href: /#{Regexp.escape(@href)}/, text: @text).exists?
        @browser.link(href: /#{Regexp.escape(@href)}/, text: @text).click
        
      else
        raise "Button not found. href: #{@href} , Text: #{@text}, Index: #{@index}"
      end
    end
  end
  
  class Buttons
    include Enumerable
    
    def initialize(buttons)
      @buttons = []
      
      buttons.each_with_index do |button, index|
        if button.visible?
          @buttons << Shotcrawl::Button.new(button, index)
        end
      end
    end
    
    def each
      @buttons.each do |button|
        yield button
      end
    end
  end
  
  class Button
    attr_reader :id, :type, :name, :value, :browser
    
    def initialize(button, index)
      @browser = button.browser
      @id = button.id
      @type = button.type
      @name = button.name
      @value = button.value
      @index = index
    end
    
    def click
      if @browser.buttons[@index].exists?
        @browser.buttons[@index].click
        
      else
        raise "Button not found. Id: #{@id} , Type: #{@type} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class Images
    include Enumerable
    
    def initialize(images)
      @images = []
      
      images.each_with_index do |image, index|
        if image.visible?
          @images << Shotcrawl::Image.new(image, index)
        end
      end
    end
    
    def each
      @images.each do |image|
        yield image
      end
    end
  end
  
  class Image
    attr_reader :id, :name, :src, :alt, :index
    
    def initialize(image, index)
      @id    = image.id
      @name  = image.name
      @src   = image.src
      @alt   = image.alt
      @index = index
    end
    
    def save(path)
      open(path, 'wb') do |file|
        file.puts Net::HTTP.get_response(URI.parse(@src)).body
      end
    end
  end
  
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
    attr_reader :id, :name, :type, :value, :options, :selected_options, :index, :browser
    
    def initialize(select_list, index)
      @browser = select_list.browser
      @id      = select_list.id
      @name    = select_list.name
      @type    = select_list.type
      @value   = select_list.value
      @options = Shotcrawl::Options.new(select_list)
      @selected_options = select_list.selected_options
      @index = index
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
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser
    
    def initialize(text_field, index)
      @browser = text_field.browser
      @id      = text_field.id
      @name    = text_field.name
      @type    = text_field.type
      @value   = text_field.value
      @placeholder = text_field.placeholder
      @index   = index
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
  
  class Radios
    include Enumerable
    
    def initialize(radios)
      @radios = []
      
      radios.each_with_index do |radio, index|
        @radios << Shotcrawl::Radio.new(radio, index)
      end
    end
    
    def each
      @radios.each do |radio|
        yield radio
      end
    end
  end
  
  class Radio
  end
  
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
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser
    
    def initialize(file_field, index)
      @browser = file_field.browser
      @id      = file_field.id
      @name    = file_field.name
      @type    = file_field.type
      @value   = file_field.value
      @placeholder = file_field.placeholder
      @index   = index
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