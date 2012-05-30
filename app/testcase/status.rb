# coding: utf-8
module Shotcrawl
  module Testcase
    class Status
      
      STATUS = {
        normal:  nil,
        success: nil,
        warning: nil,
        error:   nil
      }
      
      def initialize(status)
        if STATUS.key? status.to_sym
          @status = status.to_sym
        else
          raise ArgumentError, "invalid status code #{status}. usage: #{STATUS.keys}"
        end
      end
      
      def to_s
        @status.to_s
      end
    end
  end
end