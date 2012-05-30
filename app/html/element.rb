# coding: utf-8
module Shotcrawl
  class Elements
    attr_reader :browser
    
    def initialize(browser)
      @browser = browser
    end
    
    def link(query={})
      query = query.symbolize_keys
      
      query.each do |key, value|
        case key
          when :image_src
            @browser.links.each_with_index do |link, index|
              if link.image.src == value
                return Shotcrawl::Link.new(link, index)
              end
            end
          else
            @browser.links.each_with_index do |link, index|
              if link.__send__(key) == value
                return Shotcrawl::Link.new(link, index)
              end
            end
        end
      end
      Shotcrawl::NoElement.new @browser
    end
  end
end