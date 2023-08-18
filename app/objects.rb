path = File.dirname(__FILE__)

load "#{path}/objects/baseball_player.rb"
load "#{path}/objects/baseball_team.rb"
load "#{path}/objects/fantasy_team.rb"
load "#{path}/objects/fantrax_stat.rb"

load "#{path}/objects/fantrax_store.rb"

Obj.classes[:fantrax_stat] = Obj::FantraxStat
Obj.classes[:fantasy_team] = Obj::FantasyTeam
Obj.classes[:baseball_team] = Obj::BaseballTeam
Obj.classes[:baseball_player] = Obj::BaseballPlayer


