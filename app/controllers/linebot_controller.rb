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
        urlOdakyu = 'https://www.odakyu.jp/cgi-bin/user/emg/emergency_bbs.pl'
        charset = nil
        htmlOdakyu = open(urlOdakyu) do |f|
        charset = f.charset
        f.read
        end
        docOdakyu = Nokogiri::HTML.parse(htmlOdakyu, nil, charset)
        docOdakyu.xpath('//div[@id="pagettl"]').each do |node|
        response = 
          node.css('p').inner_text+"\n\n\n
          ↓↓番号を選択↓↓\n
          1. 開成駅→会社（シャトルバス）\n
          2. 会社→開成駅（シャトルバス）\n
          3. 電車の運行状況\n
          4. 会社周辺の天気\n
          5. 東京の天気\n\n
          ※半角数字でお願いします。"
        end
      else
        response = "www"
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