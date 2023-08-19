require 'csv'

class Obj::RotowireStatStore < Obj::BaseballStatStore
  def attach_stat(baseball_player, db_baseball_player)
    db_rotowire_stat = create_rotowire_stat(baseball_player, db_baseball_player)
    db_baseball_player.rotowire_stats.push(db_rotowire_stat) unless find_rotowire_stat(db_rotowire_stat, db_baseball_player)
  end

  def find_rotowire_stat(db_rotowire_stat, baseball_player)
    baseball_player.rotowire_stats.find do |rs|
      rs.recorded_date == db_rotowire_stat.recorded_date &&
        rs.stat_type == db_rotowire_stat.stat_type
    end
  end

  def create_rotowire_stat(baseball_player, db_baseball_player)
    rotowire_stat = baseball_player.rotowire_stats.first
    db_rotowire_stat = rotowire_stat.dup
    db_rotowire_stat.baseball_player = db_baseball_player
    @db.add_obj(db_rotowire_stat)
  end
end
