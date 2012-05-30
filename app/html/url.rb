# coding: utf-8
module Shotcrawl
  class Url
    
    class << self
      def parse(arg)
        str = arg.to_s
        
        str[/#{matcher}/].strip
      end
    
      def matcher
        "http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w\\- .\\/?%&=]*)?"
      end
    end
  end
end