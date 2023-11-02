#!/usr/bin/env ruby
require 'bundler/setup'
require 'faraday'
require 'nokogiri'
# require 'optparse'
# require 'colorize'
# require 'yaml'

# Get the current chain height from various sources and compare hashes
#
# Initial list of blocks we're interested in
blocks = [2591999, 2592000, 2592001]

# Setup the connections we're interested in
#
# Terracoin Insight
# https://github.com/terracoin/insight-api-terracoin
insight = Faraday.new(
  url: "https://insight.terracoin.io/api"
)
=begin
{"info":
  {"version":120205,
   "insightversion":"0.6.0",
   "protocolversion":70208,
   "blocks":2597770,
   "timeoffset":0,
   "connections":97,
   "proxy":"",
   "difficulty":26599997757.86481,
   "testnet":false,
   "relayfee":0.0001,
   "errors":"",
   "network":"livenet"}
}
=end

# southXchange
# https://market.southxchange.com/Home/Api (Doesn't include chain info)
southxchange = Faraday.new(
  url: "https://market.southxchange.com"
)
=begin
{"Currency"=>"TRC",
  "CurrencyName"=>"Terracoin",
  "Date"=>"2023-11-01T20:54:36.067",
  "Status"=>0,
  "Type"=>0,
  "LastBlock"=>2596603,
  "Version"=>"120205",
  "Connections"=>1,
  "RequiredConfirmations"=>25},
=end


# PosMN
#
# https://www.posmn.com/currencies/terracoin
#
# MN List from overview ?
#
# Electrum
electrum_servers = ['http://electrum.southofheaven.ca/', 'http://electrum.terracoin.io/', 'http://failover.trc-uis.ewmcx.biz/']
electrum_conns = []
electrum_servers.each do |server|
  puts "Trying #{server}"
  conn = Faraday.new(
    url: server
  ) do |c|
    c.options.timeout = 5
  end

  begin
    doc = conn.get
  rescue  Faraday::ConnectionFailed
    #Net::OpenTimeout
    puts "failed to connect to #{server}"
  else
    if doc.status == 200
      electrum_conns << conn
    end
  end
end

status = {}
# Get current heights on services
insight_status_doc = insight.get('status')
insight_status = JSON.parse(insight_status_doc.body)
puts "Insight height is #{insight_status['info']['blocks']}"
blocks << insight_status['info']['blocks']
status['insight']={}
status['insight']['height'] = insight_status['info']['blocks']
status['insight']['peers'] = insight_status['info']['connections']


southxchange_status_doc = southxchange.get('apiux/Balance/GetWalletsInfo')
southxchange_status = JSON.parse(southxchange_status_doc.body).select{|k| k['Currency'] == 'TRC'}.first
puts "SouthXchange height is #{southxchange_status['LastBlock']}"
blocks << southxchange_status['LastBlock']
status['southX']={}
status['southX']['height'] = southxchange_status['LastBlock']
status['southX']['peers'] = southxchange_status['Connections']

electrum_conns.each do |e|
  host = "E: #{e.url_prefix.host.split('.')[1]}"
  status[host]={}
  resp = e.get()
  doc = Nokogiri::HTML(resp.body)
  doc.css('div.pure-u-lg-2-3 > p').each do |p|
    case p.css('span').text
    when "Number of Connections:"
      status[host]['peers'] = p.children[1].text.strip
    when "Node Height:"
      height = p.children.last.to_s.strip.split(' ')[0].delete(',').to_i
      puts "Electrum (#{host}) height is #{height}"
      blocks << height
      status[host]['height'] = height
    when "Network Height:"
      height = p.children.last.to_s.strip.split(' ')[0].delete(',').to_i
      blocks << height
      status[host]['netheight'] = height
    end
  end
end

puts "Current status (not pretty)"
pp status

puts
blocks.uniq!
puts "Getting data for blocks #{blocks.join(', ')}"

