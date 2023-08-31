path = File.dirname(__FILE__)

load "#{path}/objects/baseball_player.rb"
load "#{path}/objects/baseball_team.rb"
load "#{path}/objects/fantasy_team.rb"
load "#{path}/objects/fantrax_stat.rb"
load "#{path}/objects/rotowire_stat.rb"

load "#{path}/objects/baseball_stat_store.rb"
load "#{path}/objects/fantrax_store.rb"
load "#{path}/objects/rotowire_stat_store.rb"
load "#{path}/objects/rotowire_prospect_store.rb"
load "#{path}/objects/rotowire_dynasty_store.rb"

Obj.classes[:fantrax_stat] = Obj::FantraxStat
Obj.classes[:rotowire_stat] = Obj::RotowireStat
Obj.classes[:fantasy_team] = Obj::FantasyTeam
Obj.classes[:baseball_team] = Obj::BaseballTeam
Obj.classes[:baseball_player] = Obj::BaseballPlayer
Obj.classes[:fantrax_store] = Obj::FantraxStore
Obj.classes[:rotowire_prospect_store] = Obj::RotowireProspectStore
Obj.classes[:rotowire_dynasty_store] = Obj::RotowireDynastyStore


