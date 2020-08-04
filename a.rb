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
        session.visit "https://trafficinfo.westjr.co.jp/sp/kinki.html"
        html5 = session.html
        doc5 = Nokogiri::HTML.parse(html5)
        jr1 = doc5.xpath('//*[@id="chiku_unkolist"]/ul/li[1]/span[1]').inner_text
        jr2 = doc5.xpath('//*[@id="chiku_unkolist"]/ul/li[1]/span[3]').inner_text
        p jr1+"\n"+jr2