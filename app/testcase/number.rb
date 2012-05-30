# coding: utf-8
module Shotcrawl
  module Testcase
    class Number
      
      def initialize
        @no = 0
      end
      
      def next
        @no += 1
      end
      
      def to_s
        @no.to_s.rjust(3, '0')
      end
    end
  end
end