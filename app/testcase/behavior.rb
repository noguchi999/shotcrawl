Dir.glob("#{File.expand_path('..', __FILE__)}/behavior/*.rb") do |f|
  next if File.basename(f) == File.basename(__FILE__)
  
  require f
end
