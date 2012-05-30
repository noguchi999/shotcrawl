# coding: utf-8
module Shotcrawl
  module Testcase
    class Result
      attr_reader :status, :message
      
      def initialize(args={})
        @status   = args[:status]
        @message  = args[:message]
      end
    end
  end
end