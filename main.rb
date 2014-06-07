require 'net/http'
require 'pry'

#require 'rlivsey-middleman'


#https://github.com/umut/http-cache
require './http-cache/lib/hoydaa/net_http_cache'
require './http-cache/lib/hoydaa/file_store'

def get(url)
	Net::HTTP.get(URI(url))	
end

def post(url,params)
	Net::HTTP.post_form(URI(url),params)	
end
# m = new Middleman
# m.options[:verbose] = true


#Hoydaa::Cache.clear_cache!
Hoydaa::Cache.cache(/.*/, :expires => -1, :store => Hoydaa::FileStore.new("./cache/",5))

get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
post('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/',:asd => 1, :dsa => 2)
post('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/',:dsa => 2 ,:asd => 1)
