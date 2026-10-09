require 'csv'

class Obj::BaseballStatStore < Obj::Store
  def initialize(db, directory, status_proc: ->(str){ puts str })
    # puts "BaseballStatStore: directory: #{directory}"
    super(status_proc: status_proc)
    @db = db
    @directory = directory
  end

  def create_baseball_players(baseball_players, update_baseball_player: false, status_proc: ->(str){})
    total = baseball_players.size
    baseball_players
      .each_with_index do |baseball_player, index|
      status_proc.call("%.2f" % [(index / total.to_f) * 100]) if index % 100 == 0

      # puts("%.2f" % [(index / total.to_f) * 100])
      # puts "looking for baseball player: #{baseball_player.remote_id}"

      db_baseball_player = find_or_add_baseball_player(baseball_player, status_proc: status_proc)
      next unless db_baseball_player

      db_baseball_team = find_or_add_baseball_team(baseball_player.baseball_team) if baseball_player.baseball_team
      db_fantasy_team = find_or_add_fantasy_team(baseball_player.fantasy_team) if baseball_player.fantasy_team

      if db_baseball_team
        db_baseball_player.baseball_team = db_baseball_team
        db_baseball_player.save
      end
      if db_fantasy_team
        db_baseball_player.fantasy_team = db_fantasy_team
        db_baseball_player.save
      end

      attach_stat(baseball_player, db_baseball_player)
    end
  end

  def find_or_add_baseball_player(baseball_player, status_proc: ->(str){})
    db_baseball_players_by_name = @db.where_by(:baseball_player, { name: baseball_player.name })
    db_baseball_player_by_name = db_baseball_players_by_name.first
    db_baseball_player_by_remote_id = @db.find_by(:baseball_player, { remote_id: baseball_player.remote_id })

    if baseball_player.remote_id.nil?
      db_baseball_player = db_baseball_player_by_name
      unless db_baseball_player
        status_proc.call("can't find player by name: #{baseball_player.name}")
      end
    else
      if db_baseball_player_by_remote_id
        db_baseball_player = db_baseball_player_by_remote_id
      else
        if db_baseball_players_by_name.size > 1
          status_proc.call("player not found with remote ID and multiple players with same name: #{baseball_player.name}")
          return nil
        else
          db_baseball_player = db_baseball_player_by_name
        end
      end
    end

    # puts "db_baseball_player: #{db_baseball_player}"
    if !db_baseball_player.nil?
      # don't overwrite the remote_id if it already exists in the db
      baseball_player.remote_id = db_baseball_player.remote_id if db_baseball_player.remote_id
      db_baseball_player.update(baseball_player, update_belongs_tos: false)
    else
      status_proc.call("adding player: #{baseball_player.name}")
      db_baseball_player = baseball_player.dup
      db_baseball_player.baseball_team = nil
      db_baseball_player.fantasy_team = nil
      db_baseball_player.fantrax_stats = []
      @db.add_obj(db_baseball_player)
    end
    db_baseball_player
  end

  def find_or_add_baseball_team(baseball_team)
    return nil unless baseball_team

    db_baseball_team = @db.find_by(:baseball_team, { name: baseball_team.name })
    return db_baseball_team if db_baseball_team

    @db.add_obj(baseball_team.dup)
  end

  def find_or_add_fantasy_team(fantasy_team)
    return nil unless fantasy_team

    # puts "fantasy_team: #{fantasy_team.name}"

    db_fantasy_team = @db.find_by(:fantasy_team, { name: fantasy_team.name })
    return db_fantasy_team if db_fantasy_team

    # puts "adding fantasy_team: #{fantasy_team.name}"
    @db.add_obj(fantasy_team.dup)
  end
end
