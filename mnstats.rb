#!/usr/bin/env ruby
require 'bundler/setup'
require 'faraday'

# require 'nokogiri'
# require 'optparse'
# require 'colorize'
# require 'yaml'
# require 'json'

params = {testnet: 0}

# https://overview.terracoin.io/data/masternodeslistfull-0.json
# https://overview.terracoin.io/api/masternodes
#

connection = Faraday.new(
  url: "https://overview.terracoin.io",
  params: {testnet: 0}
)

response = connection.get('data/masternodeslistfull-0.json')

if response.status == 200
  lastseen={"today"=>0, "week"=>0, "old"=>0}
  mn_list = JSON.parse(response.body)

  mn_list['data']['masternodes'].each do |mn|
#    pp mn
    case mn['MasternodeLastSeen']
    when (Time.now - (24*60*60)).to_i .. Time.now.to_i
      lastseen['today']+=1
    when (Time.now - (7*24*60*60)).to_i..(Time.now-(24*60*60)).to_i
      lastseen['week']+=1
    else
      lastseen['old']+=1
    end
  end

  pp lastseen
end

=begin
{"MasternodeOutputHash"=>"0011aadcd746fa35240bc23aa446e52f8690ee419bae82d282af591e31e0429e",
 "MasternodeOutputIndex"=>1,
 "MasternodeIP"=>"108.61.167.216",
 "MasternodeTor"=>"",
 "MasternodePort"=>13333,
 "MasternodePubkey"=>"1Ax5DvrVt2WZgJx5FLxhUWRH2qkQPR21p5",
 "MasternodeProtocol"=>70208,
 "MasternodeLastSeen"=>1642956401,
 "MasternodeActiveSeconds"=>54022137,
 "MasternodeLastPaid"=>0,
 "ActiveCount"=>0,
 "InactiveCount"=>4,
 "UnlistedCount"=>0,
 "MasternodeDaemonVersion"=>"",
 "MasternodeSentinelVersion"=>"1.1.0",
 "MasternodeSentinelState"=>"current",
 "LastPaidFromBlocks"=>{"MNLastPaidBlock"=>2194625, "MNLastPaidTime"=>1647267159, "MNLastPaidAmount"=>2.25},
 "Portcheck"=>
  {"Result"=>"timeout",
   "SubVer"=>"/Terracoin Core:0.12.2.4/",
   "NextCheck"=>1698961755,
   "ErrorMessage"=>"Connection timed out",
   "Country"=>"Netherlands",
   "CountryCode"=>"nl"},
 "Balance"=>{"Value"=>6770.8096895, "LastUpdate"=>1698958691}}
=end
