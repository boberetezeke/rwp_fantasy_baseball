
def best_players(team, span, positions)
  players_with_positions(team.baseball_players, positions).sort_by do |bp|
    stat = find_stat_by_span(bp, span)
    stat ?  stat.fantasy_ppg : 0.0
  end.reverse.map do |bp|
    stat = find_stat_by_span(bp, span)
    stat_dup = stat.dup
    bp_new = bp.dup
    bp_new.fantasy_team = nil
    bp_new.baseball_team = nil
    bp_new.fantrax_stats = stat_dup ? [stat_dup] : []
    bp_new
  end
end

def ascending_players(team, spans, positions)
  players_with_positions(team_players(team), positions).map do |bp|
    oldest_stat = find_stat_by_span(bp, spans[0])&.fantasy_ppg || 0.0
    newest_stat = find_stat_by_span(bp, spans[1])&.fantasy_ppg || 0.0

    if oldest_stat == 0.0 && newest_stat == 0.0
      pct_change = 0.0
    elsif oldest_stat != 0.0 && newest_stat == 0.0
      pct_change = -1000.0
    elsif oldest_stat == 0.0 && newest_stat != 0.0
      pct_change = 1000.0
    else
      pct_change = ((newest_stat - oldest_stat) / oldest_stat) * 100.0
    end

    [bp, oldest_stat, newest_stat, pct_change]
  end.sort_by{|bp, oldest_stat, newest_stat, pct_change| pct_change}
end

def team_players(team)
  if team.nil?
    @db.baseball_players.where_by(fantasy_team_id: nil)
  else
    team.baseball_players
  end
end

def players_with_positions(baseball_players, positions)
  baseball_players.select do |bp|
    !(bp.positions.split(/,/) & positions).empty?
  end
end
def bps(team, positions, num: 10, span: 60) = best_players(team, span, positions)[0..(num-1)].map{|bp| st = bp.fantrax_stats.first; [bp.name, bp.age, st&.fantasy_ppg, st&.fantasy_pts
]}

def aps(team, spans, positions) = ascending_players(team, spans, positions).map{|bp, oldest_stat, newest_stat, pct_change| [bp.name, bp.age, oldest_stat, newest_stat, pct_change]}

def team_averages(team_names, num: 10, span: 60)
  team_names.map do |tn|
    pitching_avg = bps(ffteam(tn),['SP'], num:, span:).sum{|n,a,f1,f2| f1.nil? ? 0.0 : f1}/num
    batting_avg = bps(ffteam(tn),batting_positions, num:, span:).sum{|n,a,f1,f2| f1}/num
    [
      tn,
      pitching_avg,
      batting_avg,
      pitching_avg + batting_avg
    ]
  end
end

def find_stat_by_span(bp, span)
  bp.fantrax_stats.to_a.find { |fs| fs.end_date - fs.start_date + 1 == span }
end

def batting_positions
  ['C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'UT']
end

def team_names
  @db.objs[:fantasy_team].all.map(&:name)
end

def team(name)
  @db.objs[:fantasy_team].all.find { |ft| ft.name == name }
end