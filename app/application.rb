# coding: utf-8
module Shotcrawl
  class Application
    attr_reader :browser, :current_uri
    
    $logger = Logger.new(File.expand_path("log/#{File.basename(__FILE__, '.rb')}.log"))
    
    JA = Lang.ja
    
    STATUS = {
              normal:  -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;">Normal</button></td>|},
              success: -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;background-color: #5bb75b;background-image: -moz-linear-gradient(top, #62c462, #51a351);background-image: -ms-linear-gradient(top, #62c462, #51a351);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#62c462), to(#51a351));background-image: -webkit-linear-gradient(top, #62c462, #51a351);background-image: -o-linear-gradient(top, #62c462, #51a351);background-image: linear-gradient(top, #62c462, #51a351);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#62c462', endColorstr='#51a351', GradientType=0);border-color: #51a351 #51a351 #387038;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);">Success</button></td>|},
              warning: -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;background-color: #faa732;background-image: -moz-linear-gradient(top, #fbb450, #f89406);background-image: -ms-linear-gradient(top, #fbb450, #f89406);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#fbb450), to(#f89406));background-image: -webkit-linear-gradient(top, #fbb450, #f89406);background-image: -o-linear-gradient(top, #fbb450, #f89406);background-image: linear-gradient(top, #fbb450, #f89406);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#fbb450', endColorstr='#f89406', GradientType=0);border-color: #f89406 #f89406 #ad6704;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);">Warning</button></td>|},
              error:   -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;background-color: #da4f49;background-image: -moz-linear-gradient(top, #ee5f5b, #bd362f);background-image: -ms-linear-gradient(top, #ee5f5b, #bd362f);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ee5f5b), to(#bd362f));background-image: -webkit-linear-gradient(top, #ee5f5b, #bd362f);background-image: -o-linear-gradient(top, #ee5f5b, #bd362f);background-image: linear-gradient(top, #ee5f5b, #bd362f);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ee5f5b', endColorstr='#bd362f', GradientType=0);border-color: #bd362f #bd362f #802420;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);">Failure</button></td>|}
             }
    
    COMMANDS = {
                target:   "target",
                action:   "action",
                expected: "expected"
               }
    
    def initialize(options={})
      opts = {env: :development}.merge(options.symbolize_keys)
      opts = YAML.load_file(opts[:config_file])[opts[:env].to_sym].merge(opts) if opts[:config_file]

      _browser = -> *args do
        args = args.compact
        case args.length
          when 1
            Watir::Browser.new args[0]
          when 2
            Watir::Browser.new args[0], args[1]
          else
            raise ArgumentError, "invalid argment size #{args.length}. usage: 1 or 2."
        end
      end
      
      @browser = _browser.call(opts[:driver], opts[:options])
      @current_uri = URI.parse(opts[:url])
      
      @scenarios = []
    end
    
    def scenario_write(url)
      goto url
      screenshot "public/images/#{path_to_filename(current_uri)}.png"
      
      sc_links = Shotcrawl::Links.new(@browser.links, current_uri)
      sc_forms = Shotcrawl::Forms.new(@browser.forms)
      
      build_testcases do |testcases|
        sc_links.each do |link|
          testcases << link.create_testcase
        end
        
        sc_forms.each_with_index do |sc_form, index|
          testcases << sc_form.create_testcase
          
          @scenarios << "\t#{form_no}.フォーム Id: #{sc_form.id}, Name: #{sc_form.name}, Action: #{sc_form.action} が存在します."
          sc_form.text_fields.each_with_index do |sc_text_field, index|
            text_no = (index + 1).to_s.rjust(3, '0')
            analyzer sc_text_field, text_no
          end
          sc_form.file_fields.each_with_index do |sc_file_field, index|
            file_no = (index + 1).to_s.rjust(3, '0')
            analyzer sc_file_field, file_no
          end
          sc_form.select_lists.each_with_index do |sc_select_list, index|
            select_no = (index + 1).to_s.rjust(3, '0')
            analyzer sc_select_list, select_no
          end
          sc_form.radios.each_with_index do |sc_radio, index|
            radio_no = (index + 1).to_s.rjust(3, '0')
            analyzer sc_radio, radio_no
          end
          sc_form.checkboxes.each_with_index do |sc_checkbox, index|
            checkbox_no = (index + 1).to_s.rjust(3, '0')
            analyzer sc_checkbox, checkbox_no
          end
          sc_form.buttons.each_with_index do |sc_button, index|
            button_no = (index + 1).to_s.rjust(3, '0')
            analyzer sc_button, button_no
          end
        end
      end
    end
    
    def run(scenario)
      html = Nokogiri::HTML.parse(scenario)
      
      expected = Shotcrawl::Testcase::Expected.new
      @current_uri = expected.parse(html.search("#scenario_top")).url
      
      tester(target: html.search("#scenario_top"), action: "goto", expected: expected.parse(html.search("#scenario_top")))
      html.search("tbody tr").each_with_index do |tr, index|
        case_no = tr.search(".test_no").attr("id").to_s.gsub(/test_no_/, '')
        result  = tester(target: tr.search("#target_#{case_no}"), action: tr.search("#action_#{case_no}"), expected: expected.parse(tr.search("#expected_#{case_no}")))
        tr.search("#status_#{case_no}").remove
        tr.search("#result_#{case_no}").after STATUS[result[:status]].call(case_no)
        if result[:status] == :error
          tr.search("#result_#{case_no}").first.content = result[:message]
        end
      end
      
      html.to_s
    end
    
    private
      def goto(url)
        browser.goto url.to_s
      end
    
      def screenshot(path)
        return # 一時的に利用を停止.
      
        return if URI.parse(browser.url).host != current_uri.host
        
        begin
          browser.driver.save_screenshot(path)
        rescue Timeout::Error => e
          $logger.error e
        end
      end
      
      def path_to_filename(url)
        URI.parse(url.to_s).path.gsub(/\//, "_").gsub(/^_|_$/, "")
      end
      
      def analyzer(element, no)
        case element.type
          when "text"
            @scenarios << "\t\t#{no}.#{JA[element.type.to_sym]} Id: #{element.id}, Name: #{element.name}, Value: #{element.value}, Placeholder: #{element.placeholder} が存在します."
            @scenarios << "\t\t\t#{no}.#{messanger(element, :autofocus?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :disabled?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :read_only?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :required?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :min)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :max)}"
            
          when "file"
            @scenarios << "\t\t#{no}.#{JA[element.type.to_sym]} Id: #{element.id}, Name: #{element.name}, Value: #{element.value}, Placeholder: #{element.placeholder} が存在します."
            @scenarios << "\t\t\t#{no}.#{messanger(element, :autofocus?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :disabled?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :read_only?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :required?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :min)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :max)}"
          
          when "select-one", "select-multiple"
            @scenarios << "\t\t#{no}.#{JA[element.type.to_sym]} Id: #{element.id}, Name: #{element.name} が存在します."
            @scenarios << "\t\t\t#{no}.#{messanger(element, :autofocus?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :disabled?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :required?)}"
            @scenarios << "\t\t\t#{no}.#{messanger(element, :length)}"
          
          when "radio"
            @scenarios << "\t\t#{no}.#{JA[element.type.to_sym]} Id: #{element.id}, Name: #{element.name}, Value: #{element.value} が存在します."
            @scenarios << "\t\t\t#{no}.#{messanger(element, :disabled?)}"            
          
          when "checkbox"
            @scenarios << "\t\t#{no}.#{JA[element.type.to_sym]} Id: #{element.id}, Name: #{element.name}, Value: #{element.value} が存在します."
            @scenarios << "\t\t\t#{no}.#{messanger(element, :disabled?)}"            
          
          when "button", "submit"
            @scenarios << "\t\t#{no}.#{JA[element.type.to_sym]} Id: #{element.id}, Name: #{element.name}, Type: #{element.type}, Value: #{element.value} が存在します."
            @scenarios << "\t\t\t#{no}.#{messanger(element, :disabled?)}"

          else
            raise ArgumentError, "invalid argument: #{element.type}"
        end
      end     

      def messanger(obj, method_name)
        result = obj.__send__(method_name)
        result =  case result
                    when true, false
                      JA[result.to_s.to_sym]
                    when nil, "", [], {}
                      "未設定"
                    else
                      result
                  end
        "#{JA[obj.type.to_sym]}の#{JA[method_name.to_sym]}は、#{result}です."
      end
      
      def tester(options={})
        raise ArgmentError, "invalid command #{options}. usage: #{COMMANDS.keys}" if (options.keys - COMMANDS.keys).length > 0
        
        opts = {target: nil, action: nil, expected: nil}.merge(options)
        
        elements = Shotcrawl::Elements.new @browser
        
        case opts[:target].to_s
          when /リンク画像:/
            src = opts[:target].to_s[/img.+?src\=.+?#{Shotcrawl::Url.matcher}/i].gsub(/img.+?src\=.+?/i, '').strip
            link   = elements.link(image_src: src)
            result = link.test(:click, opts[:expected])
            
          when /リンクテキスト:/
            text = opts[:target].to_s[/リンクテキスト:.+?\<\/td\>/].gsub(/リンクテキスト:|\<\/td\>/i, '').strip
            link = elements.link(text: text)
            result = link.test(:click, opts[:expected])
            
          when /#{Shotcrawl::Url.matcher}/
            @browser.goto(Shotcrawl::Url.parse(opts[:target]))
            if @browser.title == opts[:expected].title && @browser.url == opts[:expected].url
              result = {status: :success, message: ""}
            else
              result = {status: :error, message: %Q|<span id='scenario_top'>現在のページは、 Title: #{opts[:expected].title}, <br />Url: #{opts[:expected].url} です.<br /></span>|}
            end
        end
        
        goto @current_uri
        result
      end
  end
end
