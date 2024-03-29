require 'csv'

class Obj::FantraxStore < Obj::BaseballStatStore
  def get_prospect_names_hash
    prospect_names_hash = {}
    Dir["#{@directory}/../rotowire/*"].each do |fn|
      next unless fn =~ /prospects/

      csv = CSV.read(fn)
      csv[2..-1].each do |row|
        prospect_names_hash[row[0]] = true
      end
    end
    prospect_names_hash
  end

  def sync
    prospect_names_hash = get_prospect_names_hash
    Dir["#{@directory}/*"].each do |fn|
      m = /Fantrax-(\d+)-(\d+)-(\d+)--(\d+)-days/.match(fn)
      next unless m

      date = Date.new(m[1].to_i, m[2].to_i, m[3].to_i)
      days_back = m[4].to_i

      lines = CSV.open(fn, headers: true).readlines
      baseball_players = lines.map do |row|
        remote_id = row['ID']
        name = row['Player']
        team_name = row['Team']
        age = row['Age']
        positions = row['Position']
        status = row['Status']
        fantasy_pts = row['FPts'].to_f
        fantasy_ppg = row['FP/G'].to_f
        roster_pct = row['Ros %'].to_f / 100.0
        roster_pct_chg = parse_roster_pct_chg(row['+/-'])
        player = Obj::BaseballPlayer.from_csv(remote_id, name, team_name, positions, status, age)
        fantrax_stat = Obj::FantraxStat.new(date, days_back, fantasy_ppg, fantasy_pts, roster_pct, roster_pct_chg)
        player.fantrax_stats = [fantrax_stat] if fantrax_stat.fantasy_pts > 0.0
        player
      end

      baseball_players_with_stats =
        baseball_players
          .select do |bp|
          fantrax_stat = bp.fantrax_stats.first
          (fantrax_stat && fantrax_stat.fantasy_pts > 0.0) ||
            prospect_names_hash.has_key?(bp.name)
        end

      create_baseball_players(baseball_players_with_stats, status_proc: status_proc)
    end
    nil
  end

  def attach_stat(baseball_player, db_baseball_player)
    return if baseball_player.fantrax_stats.empty?

    db_fantrax_stat = create_fantrax_stat(baseball_player, db_baseball_player)
    db_baseball_player.fantrax_stats.push(db_fantrax_stat) unless find_fantrax_stat(db_fantrax_stat, db_baseball_player)
  end

  def parse_roster_pct_chg(roster_pct_chg)
    m = /([+-])?([\.\d]+)?/.match(roster_pct_chg)
    if m[2]
      if m[1] == '-'
        roster_pct_chg = -(m[2].to_f)
      else
        roster_pct_chg = m[2].to_f
      end
    else
      roster_pct_chg = 0.0
    end
    roster_pct_chg / 100.0
  end

  def find_fantrax_stat(db_fantrax_stat, baseball_player)
    baseball_player.fantrax_stats.find do |fs|
      fs.recorded_date == db_fantrax_stat.recorded_date &&
        fs.days_back == db_fantrax_stat.days_back
    end
  end

  def create_fantrax_stat(baseball_player, db_baseball_player)
    fantrax_stat = baseball_player.fantrax_stats.first
    db_fantrax_stat = fantrax_stat.dup
    db_fantrax_stat.baseball_player = db_baseball_player
    @db.add_obj(db_fantrax_stat)
  end
end
