# coding: utf-8
module Shotcrawl
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
    
    include Shotcrawl::Testable
    
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
end