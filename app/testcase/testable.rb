# coding: utf-8
module Shotcrawl
  # Shotcrawl::Testableをincludeするクラスは、Watir::Browserインスタンスを返却するbrowserメソッドを定義する必要がある.
  module Testable
    extend ActiveSupport::Concern
    
    included do
      include "Shotcrawl::Testcase::#{self.name.demodulize}".constantize
    end
  end
end