
def best_players(team, span, positions)
  team.baseball_players.select do |bp|
    !(bp.positions.split(/,/) & positions).empty?
  end.sort_by do |bp|
    stat = find_stat_by_span(bp, span)
    stat ?  stat.fantasy_ppg : 0.0
  end.reverse.map do |bp|
    stat = find_stat_by_span(bp, span)
    bp_new = bp.dup
    bp_new.fantrax_stats = stat ? [stat] : []
    bp_new
  end
end

def bps(team, positions, num: 10, span: 60) = best_players(team, span, positions)[0..(num-1)].map{|bp| st = bp.fantrax_stats.first; [bp.name, bp.age, st&.fantasy_ppg, st&.fantasy_pts
]}

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