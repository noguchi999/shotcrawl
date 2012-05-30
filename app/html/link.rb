# coding: utf-8
module Shotcrawl
  class Links
    include Enumerable
    
    def initialize(links, current_uri=nil)
      @links = []
      
      links.each_with_index do |link, index|
        if link.visible? && (link.href != link.browser.url)
          @links << Shotcrawl::Link.new(link, index: index, current_uri: current_uri)
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
    attr_reader :href, :text, :image_src, :target, :current_uri, :browser
  
    include Shotcrawl::Testable
    
    def initialize(link, options={})
      opts = {index: 0}.merge(options).symbolize_keys
      
      @browser     = link.browser
      @href        = link.href
      @text        = link.text
      @image_src   = link.image.src if link.image.exists?
      @target      = link.target
      
      @current_uri = opts[:current_uri]
      @index       = opts[:index]
    end
    
    def click
      if browser.links[@index].exists?
        browser.links[@index].click
      
      elsif browser.link(href: /#{Regexp.escape(@href)}/, text: @text).exists?
        browser.link(href: /#{Regexp.escape(@href)}/, text: @text).click
        
      else
        raise "Link not found. href: #{href} , Text: #{text}, Index: #{@index}"
      end
    end
  end
end