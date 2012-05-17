module Shotcrawl
  class Scenario
    attr_reader :name, :text, :testcases
    
    def create(name, text, testcases)
      @name = name
      @text =  text
      @testcases = testcases
    end
  end
  
  class Testcases
    include Enumerable
    
    def initialize
      @testcases = []
    end
    
    def add(testcase)
      @testcases << testcase
    end
    
    def <<(testcase)
      add(testcase)
    end
    
    def each
      @testcases.each do |testcase|
        yield testcase
      end
    end
  end
  
  class Testcase
    attr_reader :name, :target, :action, :expected, :status
    
    def initialize(browser, options={})
      opts = {name: nil, target: nil, action: nil, expected: nil, status: nil}.merge(options)
      
      @browser  = browser
      @name     = opts[:name]
      @target   = opts[:target]
      @action   = opts[:action]
      @expected = opts[:expected]
      @status   = opts[:status]
    end
  end
  
  class Action
    attr_accessor :title, :url, :click, :goto_self, :goto_blank, :link, :link_text, :link_image, :form, :button, :radio, :text, :file, :"select-one", :"select-multiple", :checkbox, :submit
  end
end