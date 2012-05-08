# coding: utf-8
require 'win32/screenshot'
require 'yaml'
require File.expand_path('lib/weblinks/weblinks')
require 'logger'

$logger = Logger.new(File.expand_path("log/#{File.basename(__FILE__, '.rb')}.log"))

module Shotcrawl
  class Base
    attr_reader :browser
    
    def initialize(browser, configuration="#{File.expand_path('config/configuration.yml')}", env=:development)
      @configuration ||= YAML.load_file(configuration)[env]
      @browser = browser
    end
    
    def analyze(url)
      @browser.goto url
      current_url = @browser.url
      
      $logger.debug @browser.text
      
      sc_links = Shotcrawl::Links.new(@browser.links)
      sc_links.each do |sc_link|
        $logger.debug "Links: #{sc_link.href} : #{sc_link.text}"
        sc_link.click
        sc_link.browser.back
      end
      
=begin
      @browser.links.each do |link|
        if link.visible?
          puts "Links: #{link.href} : #{link.text}"
          link.click
          puts "#{@browser.title} : #{@browser.url}"
          @browser.back if @browser.url != current_url
        end
      end
=end

      @browser.buttons.each do |button|
        $logger.debug "Buttons: #{button.id} : #{button.name} : #{button.type} : #{button.value}"
      end
      
      @browser.select_lists.each do |select|
        $logger.debug "SelectList: #{select.id} : #{select.name} : #{select.type} : #{select.value}"
      end
      
      @browser.text_fields.each do |field|
        $logger.debug "TextField: #{field.id} : #{field.name} : #{field.type} : #{field.value}"
      end
      
      @browser.radios.each do |radio|
        $logger.debug "Radio: #{radio}"
      end
      
    end
  end
  
  class Links
    include Enumerable
    
    def initialize(links)
      @links = []
      
      links.each do |link|
        if link.visible? && (link.href != link.browser.url)
          @links << Shotcrawl::Link.new(link)
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
    attr_reader :href, :text, :browser
    
    def initialize(link)
      @browser = link.browser
      @href = link.href
      @text = link.text
    end
    
    def click
      @browser.link(href: /#{Regexp.escape(@href)}/).click
    end
  end
  
  class Buttons
    include Enumerable
    
    def initialize(buttons)
      @buttons = []
      
      buttons.each do |button|
        if button.visible?
          @buttons << button
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
    attr_reader :id, :name, :value, :browser
    
    def initialize(button)
      @browser = button.browser
      @id = button.id
      @name = button.name
      @value = button.value
    end
    
    def click
      if @browser.button(id: @id).exist?
        @browser.button(id: @id).click
      elsif @browser.button(name: @name).exist?
        @browser.button(name: @name).click
      elsif @browser.button(value: @value).exist?
        @browser.button(value: @value).click
      end
    end
  end
end


#Win32::Screenshot::Take.of(:window, :title => /forkwell/i).write("images/image.bmp")
