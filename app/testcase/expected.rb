# coding: utf-8
module Shotcrawl
  module Testcase
    class Expected
      attr_accessor :title, :url, :id, :name, :value, :type, :placeholder, :status
      
      def initialize(options={})
        opts = options.symbolize_keys
        
        @title = opts[:title]
        @url   = opts[:url]
        @id    = opts[:id]
        @name  = opts[:name]
        @type  = opts[:type]
        @placeholder  = opts[:placeholder]
        @status = opts[:status]
      end
      
      def parse(arg)
        str    = arg.to_s
        @title = str[/title:.+?,/i].gsub(/title:|,$/i, '').strip
        @url   = str[/url:.+?#{Shotcrawl::Url.matcher}/i].gsub(/url:/i, '').strip
        @id    = str[/id:.+?;/i].gsub(/id:|,$/i, '').strip
        @name  = str[/name:.+?;/i].gsub(/name:|,$/i, '').strip
        @value = str[/value:.+?;/i].gsub(/value:|,$/i, '').strip
        @type  = str[/type:.+?;/i].gsub(/type:|,$/i, '').strip
        @placeholder = str[/placeholder:.+?;/i].gsub(/placeholder:|,$/i, '').strip
        
        self
      end
    end
  end
end