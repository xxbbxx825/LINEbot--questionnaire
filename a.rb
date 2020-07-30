require 'open-uri'
require 'nokogiri'
url1 = 'https://weather.yahoo.co.jp/weather/jp/27/6200/27107.html'
charset = nil
html1 = open(url1) do |f|
  charset = f.charset
  f.read
end
doc1 = Nokogiri::HTML.parse(html1, nil, charset)
kanjo = doc1.xpath('//div[@id="yjw_pinpoint_today"]').css('small').inner_text
p kanjo
# require 'open-uri'
# require 'nokogiri'
# url1 = 'https://transit.yahoo.co.jp/traininfo/detail/263/0/'
# charset = nil
# html1 = open(url1) do |f|
#   charset = f.charset
#   f.read
# end
# doc1 = Nokogiri::HTML.parse(html1, nil, charset)
# kanjo = doc1.xpath('//div[@id="mdServiceStatus"]').css('dt').inner_text
# url2 = 'https://transit.yahoo.co.jp/traininfo/detail/277/0/'
# charset = nil
# html2 = open(url2) do |f|
#   charset = f.charset
#   f.read
# end
# doc2 = Nokogiri::HTML.parse(html2, nil, charset)
# yamatoji = doc2.xpath('//div[@id="mdServiceStatus"]').css('dt').inner_text
# p kanjo+"\n"+yamatoji

url3 = 'https://www.jma.go.jp/jp/yoho/331.html'
charset = nil
html3 = open(url3) do |f|
  charset = f.charset
  f.read
end
doc3 = Nokogiri::HTML.parse(html3, nil, charset)
ddd = doc3.xpath('//pre[@class="textframe"]').inner_text
p ddd

# API_KEY = "2b31d52023fd8dff8d019142f0e83874"
# BASE_URL = "http://api.openweathermap.org/data/2.5/forecast"

# require "json"
# require "open-uri"

# response = open(BASE_URL + "?q=Akashi-shi,jp&APPID=#{API_KEY}")
# puts JSON.pretty_generate(JSON.parse(response.read))