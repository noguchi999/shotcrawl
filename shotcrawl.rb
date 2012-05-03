require 'win32/screenshot'
require 'watir-webdriver'

class ShotCrawl
end

Win32::Screenshot::Take.of(:window, :title => /forkwell/i).write("image.bmp")
