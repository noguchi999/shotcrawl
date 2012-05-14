# coding: utf-8
require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'active_support/core_ext'
require 'yaml'
require 'logger'

$logger = Logger.new(File.expand_path("log/#{File.basename(__FILE__, '.rb')}.log"))

module Shotcrawl
  class Base
    attr_reader :browser, :current_uri
    
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
      
      @scenarios << "現在のページは、 Title: #{@browser.title}, Url: #{@browser.url} です."
      @scenarios << "\tテキスト情報を出力します."
      @browser.text.split("\n").each do |text|
        @scenarios << "\t\t#{text}"
      end
      
      sc_links = Shotcrawl::Links.new(@browser.links)
      sc_links.each_with_index do |sc_link, index|
        link_no = (index + 1).to_s.rjust(3, '0')
        
        @scenarios << "\t#{link_no}.リンク hrel: #{sc_link.href}, リンクテキスト: #{sc_link.text}, リンク画像: #{sc_link.image_src} が存在します."
        @scenarios << "\t\t#{link_no}.リンクをクリックします."
        sc_link.click
        begin
          if sc_link.target == "_blank"
            goto sc_link.href
            @scenarios << "\t\t\tTitle: #{@browser.title}, Url: #{@browser.url} が表示されます."
            screenshot "public/images/#{path_to_filename(current_uri)}_link_to_#{path_to_filename(@browser.url)}.png"
            goto current_uri
          else
            @scenarios << "\t\t\tTitle: #{@browser.title}, Url: #{@browser.url} に遷移します."
            screenshot "public/images/#{path_to_filename(current_uri)}_link_to_#{path_to_filename(@browser.url)}.png"
          end

          goto current_uri
        rescue Selenium::WebDriver::Error::UnhandledAlertError
          @browser.driver.switch_to.alert.dismiss
          retry
        end
      end
      
      sc_forms = Shotcrawl::Forms.new(@browser.forms)
      sc_forms.each_with_index do |sc_form, index|
        form_no = (index + 1).to_s.rjust(3, '0')
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
      
      @scenarios << "Title: #{@browser.title}, Url: #{@browser.url} のシナリオは以上です."
    end
    
    def run(scenario)
      
      scenario.each do |test_case|
        if test_case[:url]
          @borwser.goto test_case[:url]
          tester()
        end
        
      end
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
      
      def tester(element, no)
        case element.type
          when "text"
          when "file"          
          when "select-one"
          when "select-multiple"
          when "radio"
          when "checkbox"
          when "button"
          when "submit"
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
    
    def initialize(link, index)
      @browser   = link.browser
      @href      = link.href
      @text      = link.text
      @image_src = link.image.src if link.image.exists?
      @target    = link.target
      @index = index
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
end