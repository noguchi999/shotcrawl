require 'nokogiri'
require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'active_support/core_ext'
require 'yaml'
require 'ostruct'
require 'logger'

require File.expand_path("../app/util", __FILE__)
require File.expand_path("../app/lang/lang", __FILE__)
require File.expand_path("../app/testcase", __FILE__)
require File.expand_path("../app/html", __FILE__)
require File.expand_path("../app/application", __FILE__)