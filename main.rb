#https://github.com/umut/http-cache
require './http-cache/lib/hoydaa/net_http_cache'
require './http-cache/lib/hoydaa/file_store'

require 'pry'
require 'net-http-spy'
require 'em-resolv-replace'

require 'nokogiri'  
require 'json'

require 'mongoid'  

def get(url)
	Net::HTTP.get(URI(url))	
end

def post(url,params)
	Net::HTTP.post_form(URI(url),params)	
end

def sq(x)
	x*x
end

Hoydaa::Cache.cache(/.*/, :expires => -1, :store => Hoydaa::FileStore.new("./cache2/",5))

ENV['MONGOID_ENV']='development'
require './models.rb'
Mongoid.load!("mongoid.yml")

matchUrl='http://www.gamestv.org/event/48259-forward-momentum-vs-hodor/'
matchUrl='http://www.gamestv.org/event/48310-8bits-vs-cat-in-a-hat/'
matchUrl='http://www.gamestv.org/event/3665-megaprogaming-e-sports-e-v-vs-edit/'
matchUrl='http://www.gamestv.org/event/5603-megaprogaming-e-sports-e-v-vs-impact-gaming/'
matchUrl='http://www.gamestv.org/event/2711-team-dignitas-the-last-resort/'
matchUrl='http://www.gamestv.org/event/6512-team-poland-belgium/'
matchUrl='http://www.gamestv.org/event/48030-new-terror-vs-craze/'
matchUrl='http://www.gamestv.org/event/5603-megaprogaming-e-sports-e-v-vs-impact-gaming/'
matchUrl='http://www.gamestv.org/event/46817-craze-vs-new-terror/'
s = get(matchUrl+'statistics/').force_encoding("ISO8859-1")

s.gsub! '<wbr>', ''
a=get(matchUrl+'analysis/').encode('UTF-8', 'UTF-8', :invalid => :replace)
i=0

doc = Nokogiri::HTML(s)
analysis_doc = Nokogiri::HTML a


players = Array.new
maps = Array.new
matchId = nil
sum = 0


analysis_doc.xpath('//select[@id="mapSelect"]/option').each { |map|
		maps << { :id => map['rel'], :name => map.text , 
			:rounds => analysis_doc.xpath('//input[@name="round"]').count.times.map { |a| { :id => a+1 , :players => [] } } }
		matchId=map.parent['rel'] unless matchId
}

#p maps

analysis_doc.xpath('//input[@name="player"]').each { |player|
	#if player['value']=='3' then binding.pry end
	nick=player.parent.parent.children.drop(1).join {|x| x.text }
	valid = false
	nick2 = nil
	doc.xpath("//div[@id='statsSummary']/fieldset/table/tbody/tr").each { |xnick|
		#p nick+'=='+xnick.xpath('./td[1]').text
		nick2 = xnick.xpath('./td[1]').text
		valid = true if (nick.include? nick2)
		binding.pry if nick=='vilazAurus'
		break if valid
	}
	p nick unless valid
	next unless valid
	players << { :nick => nick2 , :id => player['value'] , :color_nick =>player.parent.parent.children.drop(1).map {|a| a.to_html}.join}
}

p 'p:'+players.count.to_s

maps.each { |map|
#p map['rel'] + ' ' + map.text
	map[:rounds].each { |round|
		players.each { |player|
			kills = Array.new
			JSON.parse(post(matchUrl+'analysis/', {
				:jsAction => 'getKills',
				:match => matchId,
				:map => map[:id],
				:player => player[:id],
				:round => round[:id] } )).each { |k|
				kills << { :x =>k[0] , :y =>k[1], :time => k[2] ,  :killer => player[:nick]}
				sum = sum+1
			}
			binding.pry unless round[:players]
			round[:players] << { :player => player, :kills => kills }
			#binding.pry unless round[:players][player['value'].to_i]
			# round[:players] << { :kills => kills,
			# 	:nick => nick ,
			# 	:id => player['value']
			# }
			#map[:rounds] << { :kills => kills}
		}
	}
}


#p maps
p players.count

p "deaths:"

max=nil


a=0
sum2=0
maps.each { |map| 
	map[:rounds].each_with_index { |round,i|
		#p round[:players].map { |a| a[:kills].count} 
		round[:players].each { |player|
			j=JSON.parse(post(matchUrl+'analysis/', {
				:jsAction => 'getDeaths',
				:match => matchId,
				:map => map[:id],
				:player => player[:player][:id],
				:round => round[:id] } )
			)
			#p player[:id],map,round,j.count
			#binding.pry
			j.each { |d|
				sum2=sum2+1
				players.each_with_index { |pd,pi| 
					#next if pd==player
					map[:rounds][i][:players][pi][:kills].each {|k|
						#p k[:time]
						#p d[2]
						#binding.pry
						if ((k[:time]-d[2]).abs==0) then 
			 				k[:dx]=d[0]
			 				k[:dy]=d[1]
			 				k[:dist]=Math.sqrt(sq(k[:x]-k[:dx])+sq(k[:y]-k[:dy]))
			 				#p (k[:time]-d[2]).abs
			 			end
					}
					#p map[:rounds][round][:kills]
				}
			}
		}
	}
}
#p sum
#p sum2
p maps.map { |m| 
	m[:rounds].map { |r| 
		r[:players].map { |p|
			p[:kills].count
		}.reduce(:+)
	}.reduce(:+)
}.reduce(:+)


doc.xpath("//div[@class='matchStats']/fieldset").drop(1).each_with_index { |map,i|
 #p map.xpath("./legend/text()").text
 map.xpath("./table").each_with_index { |round,j|
 	#p round.xpath('./caption/text()').text
 	round.xpath('./tbody[not(@class)]/tr').each_with_index { |player,k|
 		#p '  '+player.xpath('./td[1]').text
 		kills=player.xpath('./td[@class="graph"]/span[@title and ( @class="k" or @class="tk" ) ] ')
 		kills.each_with_index { |kill,l|
 			#p 'K:   '+kill['title']
			#binding.pry unless maps[i][:rounds][j][:players][k][:kills].count==kills.count 
 			next unless maps[i][:rounds][j][:players][k][:kills].count==kills.count 
 			ddkill=maps[i][:rounds][j][:players][k][:kills][l]
 			binding.pry unless ddkill
			dkill = Hash.new
			binding.pry unless dkill
 			m = kill['title'].match(/(\d+):(\d+)\)$/)
			dkill[:mins]=m[1].to_i
			dkill[:secs]=m[2].to_i
				#p '     '+mins.to_s+':'+secs.to_s
			dkill[:killed]=kill['title'][0..kill['title'].index(' was')-1] if kill['title'].index(' was')
			#binding.pry unless kill['title'].match(/(by |spot )[^']*'s\s*([^(]*)/)
			#dkill[:weapon]=kill['title'].match(/(by |spot )[^']*'s\s*([^(]*)/)[2][0..-2]
			dkill[:weapon]=kill['title'].match(/'s ([^(]*)/)[1][0..-2]
			ddkill.merge! dkill 
			# binding.pry if i==0 && j==0 && k == 2
			# Kill.new (:killler => player, :killed => killed )
		}
 		#kills.clear
 	}
 }
}

rest_w = [ "Landmine" , "grenade", "Thompson", "MP40", "artillery support",
	"support fire", "arifle grenade" , "a.45ACP 1911" , "aLuger 9mm", "dynamite"]

max = nil
maps.each { |map| 
	map[:rounds].each { |round| 
		round[:players].each { |player|
			player[:kills].each {|k|
				if ((max == nil || max[:dist]<k[:dist] || k[:dist]>3000) && !rest_w.include?(k[:weapon])) then 
					max=k
					max[:map]={ :name => map[:name] , :id => map[:id] } 
					max[:round]=round[:id]
					#max[:killer]=player[:player][:nick]
				end
				p max
			}
		}
	}
}
p max

preview = JSON.parse(post('http://www.gamestv.org/maps/',{:mapDetails => max[:map][:name]}))

out = File.open('preview.html', 'w'); 
template=IO.read('out_template.htm');
#binding.pry 
template.gsub! '::map::', preview["image"]
template.gsub! '::k::', "[#{max[:x]},#{max[:y]}]"
template.gsub! '::d::', "[#{max[:dx]},#{max[:dy]}]"
template.gsub! '::mins::', preview["mins"].to_s
template.gsub! '::maxs::', preview["maxs"].to_s
#template.gsub! '::::', 
out.write(template)

#binding.pry
#p maps[0][:rounds][0][:players][5][:kills][3]

# http://www.gamestv.org/event/27705-team-dignitas-vs-queens/statistics/ chyba hrac v statistike -> needi pocet
# http://www.gamestv.org/event/3665-megaprogaming-e-sports-e-v-vs-edit/analysis/  2 bremeny, 1 z nich ma len 1 round
# http://www.gamestv.org/event/48259-forward-momentum-vs-hodor/ << znaky v html replace '<<','&lt;&lt' ?
# http://www.gamestv.org/event/5603-megaprogaming-e-sports-e-v-vs-impact-gaming/ 3 roundy na radare

#http://www.gamestv.org/event/5603-megaprogaming-e-sports-e-v-vs-impact-gaming/statistics/ 6:39 clown killed winghaven - wrong death coords
#http://www.gamestv.org/event/7477-buttonbashers-vs-vicious-and-evil/ spec as player