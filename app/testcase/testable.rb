# coding: utf-8
module Shotcrawl
  # Shotcrawl::Testableをincludeするクラスは、Watir::Browserインスタンスを返却するbrowserメソッドを定義する必要がある.
  module Testable
    
    def self.included(klass)
      klass.__send__ :include, eval(%Q|Shotcrawl::Testcase::#{klass.name.split("::").pop}|)
    end
  end
end