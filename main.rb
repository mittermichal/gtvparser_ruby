#https://github.com/umut/http-cache
require './http-cache/lib/hoydaa/net_http_cache'
require './http-cache/lib/hoydaa/file_store'

require 'pry'
require 'net-http-spy'
require 'em-resolv-replace'

require 'nokogiri'  

def get(url)
	Net::HTTP.get(URI(url))	
end

def post(url,params)
	Net::HTTP.post_form(URI(url),params)	
end

Hoydaa::Cache.cache(/.*/, :expires => -1, :store => Hoydaa::FileStore.new("./cache/",5))

s = get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
#get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
# p post('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/',:asd => 1, :dsa => 2)
# p post('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/',:dsa => 2 ,:asd => 1)


doc = Nokogiri::HTML(s)
doc.xpath("//div[@class='matchStats']/fieldset").drop(1).each { |map|
 p map.xpath("./legend/text()").text
 map.xpath("./table").each { |round|
 	p round.xpath('./caption/text()').text
 }
}


exit

1.times do |player|
p post('http://www.gamestv.org/event/48259-forward-momentum-vs-hodor/analysis/', {
:jsAction => "getDeaths",
:match => "48259",
:map => "66870",
:player => player.to_s,
:round => "1" } )
end
