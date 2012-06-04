# coding: utf-8
module FakedataHelper
  
  def fake_text_value(options={})
    options[:min] = 0    if options[:min].blank?
    options[:max] = 1024 if options[:max].blank?
    
    (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ("あ".."ん").to_a + ("!".."/").to_a).shuffle[options[:min]..options[:max]].join
  end
  
end