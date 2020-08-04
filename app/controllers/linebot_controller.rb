class LinebotController < ApplicationController
  require 'line/bot'
  
  protect_from_forgery :except => [:callback]
  
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
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
      require 'capybara/poltergeist'
      require 'phantomjs/poltergeist'
      require 'open-uri'
      require 'nokogiri'
      if event.message["text"].include?("1")
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
        # response = "大阪環状線"+kanjo+"\n"+"大和路線"+yamatoji
        Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 5000,phantomjs_options: [
                          '--load-images=no',
                        '--ignore-ssl-errors=yes',
                        '--ssl-protocol=any'] })
        end
        session = Capybara::Session.new(:poltergeist)
        session.driver.headers = {
            'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36"
        }
        session.visit "https://trafficinfo.westjr.co.jp/sp/kinki.html"
        html5 = session.html
        doc5 = Nokogiri::HTML.parse(html5)
        jr1 = doc5.xpath('//*[@id="chiku_unkolist"]/ul/li[1]/span[1]').inner_text
        jr2 = doc5.xpath('//*[@id="chiku_unkolist"]/ul/li[1]/span[3]').inner_text
        response = jr1+"\n"+jr2
      elsif event.message["text"].include?("2")
        url3 = 'https://www.jma.go.jp/jp/yoho/331.html'
        charset = nil
        html3 = open(url3) do |f|
          charset = f.charset
          f.read
        end
        doc3 = Nokogiri::HTML.parse(html3, nil, charset)
        wheather = doc3.xpath('//pre[@class="textframe"]').inner_text
        response = wheather

      elsif event.message["text"].include?("3")
        Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 5000,phantomjs_options: [
                                          '--load-images=no',
                                          '--ignore-ssl-errors=yes',
                                          '--ssl-protocol=any'] })
        end
        session = Capybara::Session.new(:poltergeist)
        session.driver.headers = {
            'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36"
        }
        session.visit "https://hazard.yahoo.co.jp/article/covid19osaka"
        html4 = session.html
        doc4 = Nokogiri::HTML.parse(html4)
        pandemic1 = doc4.xpath('//*[@id="box"]/div/dl[1]/div[1]').inner_text
        pandemic2 = doc4.xpath('//*[@id="box"]/div/dl[1]/div[2]').inner_text
        pandemic3 = doc4.xpath('//*[@id="box"]/div/dl[1]/div[3]').inner_text
        response = "大阪府 新型コロナ関連情報\n" + pandemic1 + "\n" + pandemic2 + "\n" + pandemic3

      else
        response = "1. JR運行情報\n2. 大阪の天気概況\n3. 新型コロナ感染状況"
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