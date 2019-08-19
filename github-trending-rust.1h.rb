#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# <bitbar.title>Github Trending</bitbar.title>
# <bitbar.version>v0.1.2</bitbar.version>
# <bitbar.author>mfks17</bitbar.author>
# <bitbar.author.github>mfks17</bitbar.author.github>
# <bitbar.desc>Github Daily Trending Viewer</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/mfks17/bitbar-plugin-github-trending/Screenshots/01.png</bitbar.image>
# <bitbar.dependencies>ruby, nokogiri</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/mfks17/bitbar-plugins-github-trending</bitbar.abouturl>

require 'open-uri'
require 'json'
require 'nokogiri'

LANG = 'rust'.freeze # your favorite language
# LANG = 'java'.freeze

url = 'https://github.com/trending/' + LANG + '?since=daily'
BASE_URL = 'https://github.com'.freeze

charset = nil
html = open(url) do |f|
  charset = f.charset
  f.read
end

hash = {}

puts LANG.capitalize
# puts '---'

doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath('//article[@class="Box-row"]').each do |node|
  repo = node.xpath('.//h1/a')
  desc = node.xpath('.//p').text.strip()
  if desc.length > 70 then
    desc = desc[0,70] + '...'
  end
  hash = { 
    name: repo.text.strip(),
    url: BASE_URL + repo.attribute('href').value,
    stars: node.xpath('.//span[contains(@class, "float-sm-right")]').text.scan(/\b[0-9]+\b/).first,
    desc: desc,
  }

  # node.xpath('.//h3/a').attribute('href').value.each_line do |s|
  #   s.slice!(0)
  #   hash = { name: s, url: BASE_URL + s, stars: "?" }

  #   # api = 'https://api.github.com/repos/' + s
  #   # begin
  #   #   res = open(api)
  #   #   code, message = res.status
  #   # rescue => _
  #   #   puts '🙅Github Api Limits🙅'
  #   #   exit
  #   # end

  #   # if code == '200'
  #   #   result = JSON.parse(res.read)
    
  #   if node.xpath('./div[4]/span[3]').text.split("\n").count == 4 then
  #   	hash[:stars] = node.xpath('./div[4]/span[3]').text.split("\n")[2].split(' ')[0]
  #   end
    #puts hash.fetch(:name)
    #puts node.xpath('./div[4]/span[3]').text.split("\n").count
    # puts hash.fetch(:name) + ' ⭐️ Daily: ' + hash.fetch(:stars) + '| sizes=14 href=' + hash.fetch(:url)
    # else
    #   puts "OMG!! #{code} #{message}"
    # end
  # end
  # hash[:desc] = node.xpath('./div[3]/p').text.strip[0,70]
  puts '---'
  puts hash.fetch(:name) + ' ⭐️ Daily: ' + hash.fetch(:stars) + '| sizes=14 href=' + hash.fetch(:url)
  puts hash.fetch(:desc)
end
