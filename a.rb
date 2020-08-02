require 'nokogiri'
require 'open-uri'
require 'capybara/poltergeist'
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
        p "大阪府 新型コロナ関連情報\n" + pandemic1 + "\n" + pandemic2 + "\n" + pandemic3 