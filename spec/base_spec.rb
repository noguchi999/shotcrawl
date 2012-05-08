# coding: utf-8
require 'rspec'
require 'watir-webdriver'
require File.expand_path("base")

describe Shotcrawl::Base, "instance when it " do
  before do
    @browser = Watir::Browser.new :chrome
    puts @browser.window.resize_to(0, 0)
    @browser.goto 'localhost:3000/graphs'
    @showcrawl = Shotcrawl::Base.new(@browser)
  end
  
  it "should analyze." do
    @showcrawl.analyze(@browser.url)
  end
  
  after do
    @browser.close
  end
end