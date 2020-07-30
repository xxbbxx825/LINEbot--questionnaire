class LinebotController < ApplicationController
  require 'line/bot'
  
  protect_from_forgery :except => [:callback]
  
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      # config.channel_secret = "your channel secret"
      # config.channel_token = "your channel token"
    }
  end
  
  def callback
    body = request.body.read
    
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end
    
    events = client.parse_events_from(body)

    events.each { |event|

      if event.message["text"].include?("1")
        require 'open-uri'
        require 'nokogiri'
        url1 = 'https://transit.yahoo.co.jp/traininfo/detail/263/0/'
        charset = nil
        html1 = open(url1) do |f|
          charset = f.charset
          f.read
        end
        doc1 = Nokogiri::HTML.parse(html1, nil, charset)
        kanjo = doc1.xpath('//div[@id="mdServiceStatus"]').css('dt').inner_text
        url2 = 'https://transit.yahoo.co.jp/traininfo/detail/277/0/'
        charset = nil
        html2 = open(url2) do |f|
          charset = f.charset
          f.read
        end
        doc2 = Nokogiri::HTML.parse(html2, nil, charset)
        yamatoji = doc2.xpath('//div[@id="mdServiceStatus"]').css('dt').inner_text
        response = "大阪環状線 "+kanjo+"\n"+"大和路線 "+yamatoji
      # elsif
      #   require 'open-uri'
      #   require 'nokogiri'
      #   url3 = 'https://www.jma.go.jp/jp/yoho/331.html'
      #   charset = nil
      #   html3 = open(url3) do |f|
      #     charset = f.charset
      #     f.read
      #   end
      #   doc3 = Nokogiri::HTML.parse(html3, nil, charset)
      #   OsakaWheather = doc3.xpath('//pre[@class="textframe"]').inner_text
      #   response =  OsakaWheather
      else
        response =
        "1. JR運行情報\n3. 電車の運行状況\n4. 会社周辺の天気\n5. 東京の天気"
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: response
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }
    head :ok
  end
end