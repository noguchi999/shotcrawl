# coding: utf-8
require 'nokogiri'
require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'active_support/core_ext'
require 'yaml'
require 'ostruct'

require File.expand_path("../app/util/nil_class", __FILE__)
require File.expand_path("../app/testcase", __FILE__)
require File.expand_path("../app/html", __FILE__)

module Shotcrawl
  class Tester
    attr_reader :browser, :current_uri
    
    include Shotcrawl::TestSuite
    
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
      
      #@browser.window.resize_to(0, 0)
    end
    
    def run
      @browser.goto @current_uri.to_s
      
      sc_links = Shotcrawl::Links.new(@browser.links, current_uri)
      sc_forms = Shotcrawl::Forms.new(@browser.forms, current_uri)
      build_testcases do |testcases|
=begin
        sc_links.each do |link|
          testcases << link.create_testcase
        end
=end

        sc_forms.each_with_index do |sc_form, index|
          
          sc_form.text_fields.each do |sc_text_field|
            testcases << sc_text_field.create_testcase
          end
=begin
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
        
          sc_form.buttons.each do |sc_button|
            testcases << sc_button.create_testcase
          end
=end
        end
      end
      
      testcases.each do |testcase|
        testcase.each do |action|
          puts action.expected.call.status
          result = action.do
          puts "#{result.status} : #{result.message}"
        end
      end
    end
  end
end

tester = Shotcrawl::Tester.new(config_file: File.expand_path('config/configuration.yml'), env: "test")
tester.run

begin
  tester.browser.close
rescue Errno::ECONNRESET => e
end