require "rtesseract"

# image = RTesseract.new()
# puts image.to_s
path = "/Users/ruby/Desktop/BFSec/bsrc.png"

image = RTesseract.read(path) do |img|
  img = img.white_threshold(245)
  img = img.quantize(256,Magick::GRAYColorspace)
end
puts image.to_s

