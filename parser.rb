require 'sinatra'
require 'open-uri'

class Property
  attr_accessor :line, :type, :tennants, :property, :pc, :tube, :rent, :bills, :length

  def initialize(line)
    @line = line
    split_lines = line.split("\t")

    # If the property type seems to be a postcode, shunt everything down one.
    if split_lines[2].match(/^\s*((GIR\s*0AA)|((([A-PR-UWYZ][0-9]{1,2})|(([A-PR-UWYZ][A-HK-Y][0-9]{1,2})|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY]))))\s*[0-9][ABD-HJLNP-UW-Z]{2}))\s*$/i)
      split_lines.insert(2, "-")
    end

    @type = split_lines[0]
    @tennants = split_lines[1].to_i
    @property = split_lines[2]
    @pc = split_lines[3]
    @tube = split_lines[4]
    @rent = split_lines[5].to_i
    @bills = split_lines[6]
    @length = split_lines[7]
  end
end

class Array
  def match_postcode(pc)
    ar = []
    self.each do |item|
      ar << item if item.pc.match(pc)
    end
    return ar
  end
end


get '/' do
  f = File.open("file.txt")
  @properties = []
  f.each_line {|l| @properties.push(Property.new(l))}

  erb :index
end

get '/danny' do
  f = File.open("file.txt")
  @properties = []
  @acceptable = []
  f.each_line {|l| @properties.push(Property.new(l))}

  @properties.each  do |p|
    if (p.type.match(/^(?:Studio|1 Bed Flat)/)) && (p.rent < 266)
      @acceptable << p
    end
  end

  w148 = @acceptable.match_postcode(/W14 8/)
  w140 = @acceptable.match_postcode(/W14 0/)
  w87 = @acceptable.match_postcode(/W8 7/)
  w86 = @acceptable.match_postcode(/W8 6/)
  w89 = @acceptable.match_postcode(/W8 9/)
  w85 = @acceptable.match_postcode(/W8 5/)
  w113 = @acceptable.match_postcode(/W11 3/)

  @ideal = w148 + w140 + w87 + w86 + w89 + w85 + w113

  w14 = @acceptable.match_postcode(/W14/)
  w8 = @acceptable.match_postcode(/W8/)
  w11 = @acceptable.match_postcode(/W11/)

  @wider = w14 + w8 + w11

  w6 = @acceptable.match_postcode(/W6/)
  w2 = @acceptable.match_postcode(/W2/)
  sw2 = @acceptable.match_postcode(/SW5/)

  @properties = w6 + w2 + sw2

  erb :index
end
