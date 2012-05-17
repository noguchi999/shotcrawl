# coding: utf-8
require 'nokogiri'
require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'active_support/core_ext'
require 'yaml'
require 'logger'

$logger = Logger.new(File.expand_path("log/#{File.basename(__FILE__, '.rb')}.log"))

module Shotcrawl
  class Base
    attr_reader :browser, :current_uri, :configuration
    
    JA = {
          true:            "有効", 
          false:           "無効",
          autofocus?:      "オートフォーカス",
          disabled?:       "無効化",
          read_only?:      "読取専用",
          required?:       "必須チェック",
          min:             "最小値",
          max:             "最大値",
          length:          "要素数",
          text:            "テキストボックス",
          file:            "ファイルボックス",
          :"select-one"      => "セレクトリスト(one)",
          :"select-multiple" => "セレクトリスト(multi)",
          radio:           "ラジオボタン",
          checkbox:        "チェックボックス",
          button:          "ボタン",
          submit:          "サブミット"
         }
    
    STATUS = {
              normal:  -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;">Normal</button></td>|},
              success: -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;background-color: #5bb75b;background-image: -moz-linear-gradient(top, #62c462, #51a351);background-image: -ms-linear-gradient(top, #62c462, #51a351);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#62c462), to(#51a351));background-image: -webkit-linear-gradient(top, #62c462, #51a351);background-image: -o-linear-gradient(top, #62c462, #51a351);background-image: linear-gradient(top, #62c462, #51a351);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#62c462', endColorstr='#51a351', GradientType=0);border-color: #51a351 #51a351 #387038;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);">Success</button></td>|},
              warning: -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;background-color: #faa732;background-image: -moz-linear-gradient(top, #fbb450, #f89406);background-image: -ms-linear-gradient(top, #fbb450, #f89406);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#fbb450), to(#f89406));background-image: -webkit-linear-gradient(top, #fbb450, #f89406);background-image: -o-linear-gradient(top, #fbb450, #f89406);background-image: linear-gradient(top, #fbb450, #f89406);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#fbb450', endColorstr='#f89406', GradientType=0);border-color: #f89406 #f89406 #ad6704;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);">Warning</button></td>|},
              error:   -> link_no {%Q|<td id='status_#{link_no}' style='text-align: center;'><button href="#" style="display: inline-block;*display: inline;*zoom: 1;padding: 4px 10px 4px;margin-bottom: 0;font-size: 13px;line-height: 18px;color: #333333;text-align: center;text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);vertical-align: middle;background-color: #f5f5f5;background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);background-image: linear-gradient(top, #ffffff, #e6e6e6);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);border-color: #e6e6e6 #e6e6e6 #bfbfbf;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);border: 1px solid #cccccc;border-bottom-color: #b3b3b3;-webkit-border-radius: 4px;-moz-border-radius: 4px;border-radius: 4px;-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);cursor: pointer;*margin-left: .3em;background-color: #da4f49;background-image: -moz-linear-gradient(top, #ee5f5b, #bd362f);background-image: -ms-linear-gradient(top, #ee5f5b, #bd362f);background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ee5f5b), to(#bd362f));background-image: -webkit-linear-gradient(top, #ee5f5b, #bd362f);background-image: -o-linear-gradient(top, #ee5f5b, #bd362f);background-image: linear-gradient(top, #ee5f5b, #bd362f);background-repeat: repeat-x;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ee5f5b', endColorstr='#bd362f', GradientType=0);border-color: #bd362f #bd362f #802420;border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);filter: progid:dximagetransform.microsoft.gradient(enabled=false);">Failure</button></td>|}
             }
    
    COMMANDS = {
                target: "target",
                action:  "action",
                expected: "expected"
               }
    
    def initialize(options={})
      opts = {config_file: "#{File.expand_path('config/configuration.yml')}", env: :development}.merge(options.symbolize_keys)
      @scenarios = []
      
      if opts[:online]
        @browser = Watir::Browser.new opts[:driver], opts[:options]
        @current_uri = URI.parse(opts[:url])
      else
        @configuration ||= YAML.load_file(opts[:config_file])[opts[:env].to_sym]
        @browser = Watir::Browser.new @configuration[:driver], @configuration[:options]
        @current_uri = URI.parse(@configuration[:url])
      end
    end
    
    def scenario_write(url)
      goto url
      screenshot "public/images/#{path_to_filename(current_uri)}.png"
      
      test_no = Shotcrawl::TestNo.new
      
      @scenarios << %Q|<span id='scenario_top'>現在のページは、 Title: #{@browser.title}, <br />Url: #{@browser.url} です.<br /></span>|
      @scenarios << "<strong>テキスト情報を出力します.</strong><br />"
      @browser.text.split("\n").each do |text|
        @scenarios << "#{text}<br />"
      end
      
      @scenarios << %Q|<table border="1">|
      @scenarios << %Q|<thead>|
      @scenarios << %Q|<tr>|
      @scenarios << %Q|<th>#</th>|
      @scenarios << %Q|<th>Target</th>|
      @scenarios << %Q|<th>Action</th>|
      @scenarios << %Q|<th>Expected</th>|
      @scenarios << %Q|<th>Result</th>|
      @scenarios << %Q|<th>Status</th>|
      @scenarios << %Q|</tr>|
      @scenarios << %Q|</thead>|
      @scenarios << %Q|<tbody>|
      
      sc_links = Shotcrawl::Links.new(@browser.links)
      sc_links.each_with_index do |sc_link, index|
        link_no = test_no.to_s
        
        @scenarios << %Q|<tr>|
        @scenarios << %Q|<td id="test_no_#{link_no}" class="test_no">#{link_no}</td>|
        @scenarios << %Q|<td id='target_#{link_no}' style="text-align: center;">|
        @scenarios << %Q|リンクテキスト: #{sc_link.text}| unless sc_link.text.blank? 
        @scenarios << %Q|リンク画像: <img src="#{sc_link.image_src}" alt="#{sc_link.image_src}" height="36px" width="36px" />| unless sc_link.image_src.blank?
        @scenarios << %Q|</td>|
        @scenarios << %Q|<td id='action_#{link_no}'>クリックする.</td>|
        sc_link.click
        begin
          if sc_link.target == "_blank"
            goto sc_link.href
            @scenarios << %Q|<td id='expected_#{link_no}'>Title: #{@browser.title}, Url: #{@browser.url} が表示されること.</td>|
            @scenarios << %Q|<td id='result_#{link_no}'></td>|
            screenshot "public/images/#{path_to_filename(current_uri)}_link_to_#{path_to_filename(@browser.url)}.png"
            if @browser.title[/error|エラー|404|not found/i]
              @scenarios << STATUS[:warning].call(link_no)
            else
              @scenarios << STATUS[:normal].call(link_no)
            end
            
            goto current_uri
          else
            @scenarios << %Q|<td id='expected_#{link_no}'>Title: #{@browser.title}, Url: #{@browser.url} に遷移すること.</td>|
            @scenarios << %Q|<td id='result_#{link_no}'></td>|
            screenshot "public/images/#{path_to_filename(current_uri)}_link_to_#{path_to_filename(@browser.url)}.png"
            if @browser.title.to_s[/error|エラー|404|not found/i]
              @scenarios << STATUS[:warning].call(link_no)
            else
              @scenarios << STATUS[:normal].call(link_no)
            end
          end
          
          goto current_uri
        rescue Selenium::WebDriver::Error::UnhandledAlertError
          @browser.driver.switch_to.alert.dismiss
          retry
        end
        @scenarios << %Q|</tr>|
        test_no.add
      end
      @scenarios << %Q|</tbody>|
      @scenarios << %Q|</table>|
      
      sc_forms = Shotcrawl::Forms.new(@browser.forms)
      sc_forms.each_with_index do |sc_form, index|
        form_no = test_no.to_s
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
        test_no.add
      end
      
      @scenarios << "Title: #{@browser.title}, Url: #{@browser.url} のシナリオは以上です."
    end
    
    def run(scenario)
      #scenario = "<span id=\"scenario_top\">現在のページは、 Title: 株式会社ヘッドウォータース 新卒採用2013 アツオモロい採用情報サイト, <br />Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/ です.<br /></span><strong>テキスト情報を出力します.</strong><br />株式会社ヘッドウォータース 2013 新卒採用情報サイト<br />&copy;Headwaters Co.,Ltd. 2012 . All rights reserved.</p>\r\n<table border=\"1\">\r\n<thead>\r\n<tr><th>#</th><th>Target</th><th>Action</th><th>Expected</th><th>Result</th><th>Status</th></tr>\r\n</thead>\r\n<tbody>\r\n<tr>\r\n<td id=\"test_no_001\" class=\"test_no\">001</td>\r\n<td id=\"target_001\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic1-2.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic1-2.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_001\">クリックする.</td>\r\n<td id=\"expected_001\">Title: 株式会社ヘッドウォータース 新卒採用2013 アツオモロい採用情報サイト, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/ に遷移すること.</td>\r\n<td id=\"result_001\">&nbsp;</td>\r\n<td id=\"status_001\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_002\" class=\"test_no\">002</td>\r\n<td id=\"target_002\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic2-2.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic2-2.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_002\">クリックする.</td>\r\n<td id=\"expected_002\">Title: 株式会社ヘッドウォータース 新卒採用2013 アツオモロい採用情報サイト, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/ に遷移すること.</td>\r\n<td id=\"result_002\">&nbsp;</td>\r\n<td id=\"status_002\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_003\" class=\"test_no\">003</td>\r\n<td id=\"target_003\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic3-2.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic3-2.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_003\">クリックする.</td>\r\n<td id=\"expected_003\">Title: 株式会社ヘッドウォータース 新卒採用2013 アツオモロい採用情報サイト, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/ に遷移すること.</td>\r\n<td id=\"result_003\">&nbsp;</td>\r\n<td id=\"status_003\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_004\" class=\"test_no\">004</td>\r\n<td id=\"target_004\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic1-1.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_topic1-1.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_004\">クリックする.</td>\r\n<td id=\"expected_004\">Title: サイヨウジャー, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/saiyou/saiyou_top.html に遷移すること.</td>\r\n<td id=\"result_004\">&nbsp;</td>\r\n<td id=\"status_004\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_005\" class=\"test_no\">005</td>\r\n<td id=\"target_005\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_book.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_book.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_005\">クリックする.</td>\r\n<td id=\"expected_005\">Title: ビジネス書籍：生き残るＳＥ｜著：株式会社ヘッドウォータース 代表取締役 篠田庸介｜出版：日本実業出版社, Url: http://www.headwaters.co.jp/book_info/ が表示されること.</td>\r\n<td id=\"result_005\">&nbsp;</td>\r\n<td id=\"status_005\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_006\" class=\"test_no\">006</td>\r\n<td id=\"target_006\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_pblog.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_pblog.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_006\">クリックする.</td>\r\n<td id=\"expected_006\">Title: 会長ブログ（株式会社ヘッドウォータース代表取締役：篠田庸介）, Url: http://www.headwaters.co.jp/blog/shinoda/index.html が表示されること.</td>\r\n<td id=\"result_006\">&nbsp;</td>\r\n<td id=\"status_006\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_007\" class=\"test_no\">007</td>\r\n<td id=\"target_007\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_blog.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_blog.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_007\">クリックする.</td>\r\n<td id=\"expected_007\">Title: エラー｜Ameba(アメーバブログ), Url: http://ameblo.jp/mado-ringo/ が表示されること.</td>\r\n<td id=\"result_007\">&nbsp;</td>\r\n<td id=\"status_007\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #faa732; background-image: linear-gradient(top, #fbb450, #f89406); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Warning</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_008\" class=\"test_no\">008</td>\r\n<td id=\"target_008\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_pdf.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_pdf.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_008\">クリックする.</td>\r\n<td id=\"expected_008\">Title: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/dl/pamphlet.pdf, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/dl/pamphlet.pdf が表示されること.</td>\r\n<td id=\"result_008\">&nbsp;</td>\r\n<td id=\"status_008\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_009\" class=\"test_no\">009</td>\r\n<td id=\"target_009\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_award2012.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_award2012.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_009\">クリックする.</td>\r\n<td id=\"expected_009\">Title: ヘッドウォータース | 就活アワード, Url: http://2012.shukatsu-award.com/2012/prize/company/post-16.html が表示されること.</td>\r\n<td id=\"result_009\">&nbsp;</td>\r\n<td id=\"status_009\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_010\" class=\"test_no\">010</td>\r\n<td id=\"target_010\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_gourmet.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_gourmet.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_010\">クリックする.</td>\r\n<td id=\"expected_010\">Title: ぐるめコレった｜紹介ページ, Url: http://gcole.jp/gcole_information.html が表示されること.</td>\r\n<td id=\"result_010\">&nbsp;</td>\r\n<td id=\"status_010\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_011\" class=\"test_no\">011</td>\r\n<td id=\"target_011\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_about.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_banner_about.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_011\">クリックする.</td>\r\n<td id=\"expected_011\">Title: チーム紹介, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/team/profile.html に遷移すること.</td>\r\n<td id=\"result_011\">&nbsp;</td>\r\n<td id=\"status_011\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_012\" class=\"test_no\">012</td>\r\n<td id=\"target_012\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_staff/top_staff_noda.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_staff/top_staff_noda.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_012\">クリックする.</td>\r\n<td id=\"expected_012\">Title: 社員紹介 青柳 佳奈子, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/staff/staff_aoyagi.html に遷移すること.</td>\r\n<td id=\"result_012\">&nbsp;</td>\r\n<td id=\"status_012\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_013\" class=\"test_no\">013</td>\r\n<td id=\"target_013\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_logo.jpg\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_logo.jpg\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_013\">クリックする.</td>\r\n<td id=\"expected_013\">Title: 株式会社ヘッドウォータース 新卒採用2013 アツオモロい採用情報サイト, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/index.html に遷移すること.</td>\r\n<td id=\"result_013\">&nbsp;</td>\r\n<td id=\"status_013\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_014\" class=\"test_no\">014</td>\r\n<td id=\"target_014\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav01_off.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav01_off.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_014\">クリックする.</td>\r\n<td id=\"expected_014\">Title: 会長インタビュー, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/president/interview.html に遷移すること.</td>\r\n<td id=\"result_014\">&nbsp;</td>\r\n<td id=\"status_014\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_015\" class=\"test_no\">015</td>\r\n<td id=\"target_015\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav02_off.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav02_off.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_015\">クリックする.</td>\r\n<td id=\"expected_015\">Title: 経営理念, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/about/vision.html に遷移すること.</td>\r\n<td id=\"result_015\">&nbsp;</td>\r\n<td id=\"status_015\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_016\" class=\"test_no\">016</td>\r\n<td id=\"target_016\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav03_off.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav03_off.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_016\">クリックする.</td>\r\n<td id=\"expected_016\">Title: 事業部紹介, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/work/work_top.html に遷移すること.</td>\r\n<td id=\"result_016\">&nbsp;</td>\r\n<td id=\"status_016\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_017\" class=\"test_no\">017</td>\r\n<td id=\"target_017\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav04_off.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav04_off.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_017\">クリックする.</td>\r\n<td id=\"expected_017\">Title: 社員紹介, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/staff/staff_top.html に遷移すること.</td>\r\n<td id=\"result_017\">&nbsp;</td>\r\n<td id=\"status_017\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_018\" class=\"test_no\">018</td>\r\n<td id=\"target_018\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav05_off.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav05_off.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_018\">クリックする.</td>\r\n<td id=\"expected_018\">Title: サイヨウジャー, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/saiyou/saiyou_top.html に遷移すること.</td>\r\n<td id=\"result_018\">&nbsp;</td>\r\n<td id=\"status_018\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n<tr>\r\n<td id=\"test_no_019\" class=\"test_no\">019</td>\r\n<td id=\"target_019\" style=\"text-align: center;\">リンク画像: <img src=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav06_off.png\" alt=\"http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/img/contents/top/top_nav/top_nav06_off.png\" width=\"36px\" height=\"36px\" /></td>\r\n<td id=\"action_019\">クリックする.</td>\r\n<td id=\"expected_019\">Title: チーム紹介, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/contents/team/profile.html に遷移すること.</td>\r\n<td id=\"result_019\">&nbsp;</td>\r\n<td id=\"status_019\"><button style=\"display: inline-block; *display: inline; *zoom: 1; padding: 4px 10px 4px; margin-bottom: 0; font-size: 13px; line-height: 18px; color: #333333; text-align: center; text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75); vertical-align: middle; background-color: #f5f5f5; background-image: linear-gradient(top, #ffffff, #e6e6e6); background-repeat: repeat-x; filter: progid:dximagetransform.microsoft.gradient(enabled=false); border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25); border: 1px solid #cccccc; border-bottom-color: #b3b3b3; -webkit-border-radius: 4px; -moz-border-radius: 4px; border-radius: 4px; -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05); cursor: pointer; *margin-left: .3em;\">Normal</button></td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n<p>Title: 株式会社ヘッドウォータース 新卒採用2013 アツオモロい採用情報サイト, Url: http://ec2-46-51-232-200.ap-northeast-1.compute.amazonaws.com/2013/madorin/ のシナリオは以上です."

      html = Nokogiri::HTML.parse(scenario)
      
      expected = Shotcrawl::Expected.new
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
        return nil if URI.parse(browser.url).host != current_uri.host
        
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
  
  class Elements
    attr_reader :browser
    
    def initialize(browser)
      @browser = browser
    end
    
    def link(query={})
      query = query.symbolize_keys

      query.each do |key, value|
        case key
          when :image_src
            @browser.links.each_with_index do |link, index|
              if link.image.src == value
                return Shotcrawl::Link.new(link, index)
              end
            end
          else
            @browser.links.each_with_index do |link, index|
              if link.__send__(key) == value
                return Shotcrawl::Link.new(link, index)
              end
            end
        end
      end
      Shotcrawl::NoElement.new @browser
    end
  end
  
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
  
  class Links
    include Enumerable
    
    def initialize(links)
      @links = []
      
      links.each_with_index do |link, index|
        if link.visible? && (link.href != link.browser.url)
          @links << Shotcrawl::Link.new(link, index)
        end
      end
    end
    
    def each
      @links.each do |link|
        yield link
      end
    end
  end
  
  class Link
    attr_reader :href, :text, :image_src, :target, :browser
    
    def initialize(link, index=0)
      @browser   = link.browser
      @href      = link.href
      @text      = link.text
      @image_src = link.image.src if link.image.exists?
      @target    = link.target
      @index     = index
    end
    
    def click
      if @browser.links[@index].exists?
        @browser.links[@index].click
      
      elsif @browser.link(href: /#{Regexp.escape(@href)}/, text: @text).exists?
        @browser.link(href: /#{Regexp.escape(@href)}/, text: @text).click
        
      else
        raise "Button not found. href: #{@href} , Text: #{@text}, Index: #{@index}"
      end
    end
    
    def test(action, expected)
      self.__send__(action)
      
      if @target == '_blank'
        @browser.goto @href
        suffix = " が表示されました."
      else
        suffix = " に遷移しました."
      end
      
      if @browser.title == expected.title && @browser.url == expected.url
        result = {status: :success, message: ""}
      else
        result = {status: :error, message: %Q|Title: #{@browser.title}, Url: #{@browser.url}#{suffix}|}
      end
      
      #$logger.debug "link_test_log: #{status}: No: #{@index}, #{@browser.title} : #{expected.title}, #{@browser.url} : #{expected.url}"
      result
    end
  end
  
  class Forms
    include Enumerable
    
    def initialize(forms)
      @forms = []
      
      forms.each_with_index do |form, index|
        if form.visible?
          @forms << Shotcrawl::Form.new(form, index)
        end
      end
    end
    
    def each
      @forms.each do |form|
        yield form
      end
    end
  end
  
  class Form
    attr_reader :id, :name, :action, :buttons, :select_lists, :text_fields, :radios, :checkboxes, :file_fields, :textareas, :index, :browser
    
    def initialize(form, index)
      @browser      = form.browser
      @id           = form.id
      @name         = form.name
      @action       = form.action
      @buttons      = Shotcrawl::Buttons.new form.buttons
      @select_lists = Shotcrawl::SelectLists.new form.select_lists
      @text_fields  = Shotcrawl::TextFields.new form.text_fields
      @radios       = Shotcrawl::Radios.new form.radios
      @checkboxes   = Shotcrawl::Checkboxes.new form.checkboxes
      @file_fields  = Shotcrawl::FileFields.new form.file_fields
      @textareas    = Shotcrawl::Textareas.new form.textareas
      @index        = index
    end
  end
  
  class Buttons
    include Enumerable
    
    def initialize(buttons)
      @buttons = []
      
      buttons.each_with_index do |button, index|
        if button.visible?
          @buttons << Shotcrawl::Button.new(button, index)
        end
      end
    end
    
    def each
      @buttons.each do |button|
        yield button
      end
    end
  end
  
  class Button
    attr_reader :id, :type, :name, :value, :browser
    
    def initialize(button, index)
      @browser  = button.browser
      @id       = button.id
      @type     = button.type
      @name     = button.name
      @value    = button.value
      @index    = index
      @disabled = button.disabled?
    end
    
    def disabled?
      @disabled
    end
    
    def click
      if @browser.buttons[@index].exists?
        @browser.buttons[@index].click
        
      else
        raise "Button not found. Id: #{@id} , Type: #{@type} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class Images
    include Enumerable
    
    def initialize(images)
      @images = []
      
      images.each_with_index do |image, index|
        if image.visible?
          @images << Shotcrawl::Image.new(image, index)
        end
      end
    end
    
    def each
      @images.each do |image|
        yield image
      end
    end
  end
  
  class Image
    attr_reader :id, :name, :src, :alt, :index
    
    def initialize(image, index)
      @id    = image.id
      @name  = image.name
      @src   = image.src
      @alt   = image.alt
      @index = index
    end
    
    def save(path)
      open(path, 'wb') do |file|
        file.puts Net::HTTP.get_response(URI.parse(@src)).body
      end
    end
  end
  
  class SelectLists
    include Enumerable
    
    def initialize(select_lists)
      @select_lists = []
      
      select_lists.each_with_index do |select_list, index|
        @select_lists << Shotcrawl::SelectList.new(select_list, index)
      end
    end
    
    def each
      @select_lists.each do |select_list|
        yield select_list
      end
    end
  end
  
  class SelectList
    attr_reader :id, :name, :type, :value, :options, :selected_options, :index, :browser, :length
    
    def initialize(select_list, index)
      @browser = select_list.browser
      @id      = select_list.id
      @name    = select_list.name
      @type    = select_list.type
      @value   = select_list.value
      @options = Shotcrawl::Options.new(select_list)
      @selected_options = select_list.selected_options
      @index      = index
      @autofocus  = select_list.autofocus?
      @disabled   = select_list.disabled?
      @required   = select_list.required?
      @length     = select_list.length
    end
    
    def autofocus?
      @autofocus
    end
    
    def disabled?
      @disabled
    end
    
    def required?
      @required
    end
    
    def option(selector={})
      selector = selector.symbolize_keys
    
      if @browser.select_list.options[@index].exists?
        @browser.select_list.options[@index].select
        
      else
        raise "Option not found. #{selector.to_s}"
      end
    end
  end
  
  class Options
    include Enumerable
    
    def initialize(select_list)
      @optoins = []
      
      select_list.options.each_with_index do |option, index|
        @optoins << Shotcrawl::Option.new(option, index, select_list)
      end
    end
    
    def each
      @optoins.each do |option|
        yield option
      end
    end
  end
  
  class Option
    attr_reader :id, :name, :value, :index, :browser
    
    def initialize(option, index, select_list)
      @browser = option.browser
      @id      = option.id
      @label   = option.label
      @value   = option.value
      @index   = index
      @select_list_id    = select_list.id
      @select_list_name  = select_list.name
      @select_list_type  = select_list.type
      @select_list_value = select_list.value
    end
    
    def select
      if @browser.select_list(id: @select_list_id).exists?
        select_list = @browser.select_list(id: @select_list_id)
        
      elsif @browser.select_list(name: @select_list_name, type: @select_list_type).exists?
        select_list = @browser.select_list(name: @select_list_name, type: @select_list_type)
        
      elsif @browser.select_list(value: @value, type: @select_list_type).exists?
        select_list = @browser.select_list(value: @value, type: @select_list_type)
        
      else
        raise "SelectList not found. Id: #{@select_list_id}, Name: #{@select_list_name}, Type: #{@select_list_type}, Value: #{@select_list_value}"
      end
      
      if select_list.option(id: @id).exists?
        select_list.option(id: @id).select
        
      elsif select_list.option(label: @label, type: @type).exists?
        select_list.option(label: @label, type: @type).select
        
      elsif select_list.option(value: @value, type: @type).exists?
        select_list.option(value: @value, type: @type).select
        
      elsif select_list.options[@index].exists?
        select_list.options[@index].select
        
      else
        raise "Option not found. Id: #{@id}, Name: #{@name}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class TextFields
    include Enumerable
    
    def initialize(text_fields)
      @text_fields = []
      
      text_fields.each_with_index do |text_field, index|
        @text_fields << Shotcrawl::TextField.new(text_field, index)
      end
    end
    
    def each
      @text_fields.each do |text_field|
        yield text_field
      end
    end
  end
  
  class TextField
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser, :min, :max
    
    def initialize(text_field, index)
      @browser = text_field.browser
      @id      = text_field.id
      @name    = text_field.name
      @type    = text_field.type
      @value   = text_field.value
      @placeholder = text_field.placeholder
      @index      = index
      @autofocus  = text_field.autofocus?
      @disabled   = text_field.disabled?
      @read_only  = text_field.read_only?
      @required   = text_field.required?
      @min        = text_field.min
      @max        = text_field.max
    end
    
    def autofocus?
      @autofocus
    end
    
    def disabled?
      @disabled
    end
    
    def read_only?
      @read_only
    end 
    
    def required?
      @required
    end
    
    def value=(arg)
      if @browser.text_fields[@index].exists?
        @browser.text_fields[@index].value = arg
        @value = arg
      
      else
        raise "TextField not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class Radios
    include Enumerable
    
    def initialize(radios)
      @radios = []
      
      radios.each_with_index do |radio, index|
        @radios << Shotcrawl::Radio.new(radio, index)
      end
    end
    
    def each
      @radios.each do |radio|
        yield radio
      end
    end
  end
  
  class Radio
    attr_reader :id, :type, :name, :value, :browser
    
    def initialize(radio, index)
      @browser  = radio.browser
      @id       = radio.id
      @type     = radio.type
      @name     = radio.name
      @value    = radio.value
      @index    = index
      @disabled = radio.disabled?
    end
    
    def disabled?
      @disabled
    end
    
    def click
      if @browser.radios[@index].exists?
        @browser.radios[@index].click
        
      else
        raise "Radio not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class Checkboxes
    include Enumerable
    
    def initialize(checkboxes)
      @checkboxes = []
      
      checkboxes.each_with_index do |checkbox, index|
        @checkboxes << Shotcrawl::Checkbox.new(checkbox, index)
      end
    end
    
    def each
      @checkboxes.each do |checkbox|
        yield checkbox
      end
    end
  end
  
  class Checkbox
    attr_reader :id, :type, :name, :value, :browser
    
    def initialize(checkbox, index)
      @browser  = checkbox.browser
      @id       = checkbox.id
      @type     = checkbox.type
      @name     = checkbox.name
      @value    = checkbox.value
      @index    = index
      @disabled = checkbox.disabled?
    end
    
    def disabled?
      @disabled
    end
    
    def click
      if @browser.checkboxes[@index].exists?
        @browser.checkboxes[@index].click
        
      else
        raise "Checkbox not found. Id: #{@id} , Name: #{@name} , Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class FileFields
    include Enumerable
    
    def initialize(file_fields)
      @file_fields = []
      
      file_fields.each_with_index do |file_field, index|
        @file_fields << Shotcrawl::FileField.new(file_field, index)
      end
    end
    
    def each
      @file_fields.each do |file_field|
        yield file_field
      end
    end
  end
  
  class FileField
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser, :min, :max
    
    def initialize(file_field, index)
      @browser = file_field.browser
      @id      = file_field.id
      @name    = file_field.name
      @type    = file_field.type
      @value   = file_field.value
      @placeholder = file_field.placeholder
      @index      = index
      @autofocus  = file_field.autofocus?
      @disabled   = file_field.disabled?
      @read_only  = file_field.read_only?
      @required   = file_field.required?
      @min        = file_field.min
      @max        = file_field.max
    end
    
    def autofocus?
      @autofocus
    end
    
    def disabled?
      @disabled
    end
    
    def read_only?
      @read_only
    end 
    
    def required?
      @required
    end
    
    def set(arg)
      if @browser.file_fields[@index].exists?
        @browser.file_fields[@index].set arg
        @value = arg
      
      else
        raise "FileField not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class Textareas
    include Enumerable
    
    def initialize(textareas)
      @textareas = []
      
      textareas.each_with_index do |textarea, index|
        @textareas << Shotcrawl::Textarea.new(textarea, index)
      end
    end
    
    def each
      @textareas.each do |textarea|
        yield textarea
      end
    end
  end
  
  class Textarea
    attr_reader :id, :name, :type, :value, :placeholder, :index, :browser
    
    def initialize(textarea, index)
      @browser = textarea.browser
      @id      = textarea.id
      @name    = textarea.name
      @type    = textarea.type
      @value   = textarea.value
      @placeholder = textarea.placeholder
      @index   = index
    end
    
    def value=(arg)
      if @browser.textareas[@index].exists?
        @browser.textareas[@index].value = arg
        @value = arg
      
      else
        raise "Textareas not found. Id: #{@id}, Name: #{@name}, Type: #{@type}, Value: #{@value}, Index: #{@index}"
      end
    end
  end
  
  class Expected
    attr_reader :title, :url, :id, :name, :value, :type, :placeholder
        
    def parse(arg)
      str    = arg.to_s
      @title = str[/title:.+?,/i].gsub(/title:|,$/i, '').strip
      @url   = str[/url:.+?#{Shotcrawl::Url.matcher}/i].gsub(/url:/i, '').strip
      @id    = str[/id:.+?;/i].gsub(/id:|,$/i, '').strip
      @name  = str[/name:.+?;/i].gsub(/name:|,$/i, '').strip
      @value = str[/value:.+?;/i].gsub(/value:|,$/i, '').strip
      @type  = str[/type:.+?;/i].gsub(/type:|,$/i, '').strip
      @placeholder = str[/placeholder:.+?;/i].gsub(/placeholder:|,$/i, '').strip
      
      #$logger.debug "expected_log: #{@title}, #{@url}, #{str}"
      
      self
    end
  end
  
  class NoElement
    attr_reader :browser
    
    def initialize(browser)
      @browser = browser
    end
    
    def click
      @browser.goto "about:blank"
    end
    
    def test(*args)
      {status: :error, message: "指定の要素は存在しません."}
    end
  end
  
  class TestNo
    
    def initialize
      @no = 1
    end
    
    def add
      @no += 1
    end
    
    def to_s
      @no.to_s.rjust(3, '0')
    end
  end
end

class NilClass

  def strip
    nil
  end
  
  def gsub(*args)
    nil
  end
end