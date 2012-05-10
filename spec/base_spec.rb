# coding: utf-8
require 'rspec'
require File.expand_path("base")

describe Shotcrawl::Base, "instance when it " do
  before do
    @showcrawl = Shotcrawl::Base.new(env: "test")
    @showcrawl.browser.window.resize_to(0, 0)
  end
  
  it "should scenario." do
    @showcrawl.scenario_write(@showcrawl.configuration[:url])
  end
  
  after do
    begin
      @showcrawl.browser.close
    rescue Errno::ECONNRESET => e
      puts e
    end
  end
end