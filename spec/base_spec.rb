# coding: utf-8
require 'rspec'
require File.expand_path("base")

describe Shotcrawl::Base, "instance when it " do
  before do
    @showcrawl = Shotcrawl::Base.new(env: "test")
    #@showcrawl.browser.window.resize_to(0, 0)
  end
  
  it "should analyze." do
    @showcrawl.analyze(@showcrawl.configuration[:url])
  end
  
  after do
    begin
      @showcrawl.browser.close
    rescue Errno::ECONNRESET => e
      puts e
    end
  end
end