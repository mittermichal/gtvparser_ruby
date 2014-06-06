require 'net/http'
require 'pry'

#require 'rlivsey-middleman'


#https://github.com/umut/http-cache
require './http-cache/lib/hoydaa/net_http_cache'
require './http-cache/lib/hoydaa/file_store'

def get(url)
	Net::HTTP.get(URI(url))	
end
# m = new Middleman
# m.options[:verbose] = true


#Hoydaa::Cache.clear_cache!
Hoydaa::Cache.cache(/.*/, :expires => 10, :store => Hoydaa::FileStore.new("./cache/",5))

get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
get('http://www.gamestv.org/event/48176-outraged-esports-vs-sstat/statistics/')
