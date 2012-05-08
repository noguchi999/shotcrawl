# coding: utf-8
require 'rubygems'
require 'capybara-webkit'
require 'headless'
require 'yaml'
require File.expand_path('lib/weblinks/weblinks')

class ShotcrawlHeadless

  def initialize(configuration="#{File.expand_path('config/configuration.yml')}", env=:development)
    @configuration ||= YAML.load_file(configuration)[env]
    
  end
  
  def weblinks
    @weblinks ||= Weblinks.new(url: @configuration[:url])
    
    @weblinks
  end  
  
  def render_all
    weblinks.to_a.each do |link|
      title = well_formed(link[:title])
      render(url: link[:url], output_path: "#{File.expand_path('images')}/#{title}.png")
    end
  end
  
  def render(options={url: nil, output_path: nil})
    opts = {url: "http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/", output_path: "images/madorin_top.png"}.merge(options)
    
    Headless.ly do
      driver = Capybara::Driver::Webkit.new("web_capture")
      driver.visit opts[:url]
      driver.render opts[:output_path]
    end
  end
  
  private
    def well_formed(file_name)
      well_formed_file_name = file_name
      if well_formed_file_name[/[^\x01-\x7E]/]
        well_formed_file_name = 
      end
      well_formed_file_name
    end
end