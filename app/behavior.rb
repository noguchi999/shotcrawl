module Shotcrawl
  module Behavior
    
    def page_info
      Action.new(title: @browser.title, url: @browser.url)
    end
    
    def page_text_print
      "テキスト情報を出力します."
      @browser.text.split("\n").each do |text|
        @scenarios << "#{text}"
      end
    end
    
    def parse(str)
      behavior = nil
      
      if str[/^現在のページは.+?/]
        title = str[/Title:.+?,/].gsub(/^Title:|,$/, '').strip
        url   = str[/Url:.+?\s/].gsub(/^Url:|\s$/, '').strip
        behavior = -> title, url {@action.title = title; @action.url = url} 
      end 
    end
  end
end