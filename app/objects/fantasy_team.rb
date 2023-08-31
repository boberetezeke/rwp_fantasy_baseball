class Obj::FantasyTeam < Obj
  has_many :baseball_players, :basebase_player, :fantasy_team_id, inverse_of: :fantasy_team

  def self.default_display
    {
      sym_sets: {
        default: [:id, :name]
      },
      fields: {
        id: { width: 35, type: :string, title: 'ID' },
        name: { width: 20, type: :string, title: 'team name' },
      }
    }
  end

  def initialize(name)
    super(:fantasy_team, {name: name})
  end

  def player_average(stats)
    sum = stats.sum
    (sum / (stats.size > 0 ? stats.size : 1)).round(2)
  end

  def top_players(days_back, pitchers, num)
    pitchers.map do |p|
      p.fantrax_stats_by_days_back(days_back)&.fantasy_ppg || 0.0
    end.sort.reverse[0..(num-1)]
  end

  def starting_pitcher_average(days_back)
    pitchers = baseball_players.select { |bp| bp.starting_only_pitcher? }
    player_average(top_players(days_back, pitchers, 10))
  end

  def relief_pitcher_average(days_back)
    pitchers = baseball_players.select { |bp| bp.relief_only_pitcher? }
    player_average(top_players(days_back, pitchers, 4))
  end

  def hitter_average(days_back)
    hitters = baseball_players.select { |bp| bp.hitter? }
    player_average(top_players(days_back, hitters, 12))
  end

  def starting_players_average(days_back)
    players =
      top_players(days_back, baseball_players.select(&:hitter?), 12) +
      top_players(days_back, baseball_players.select(&:starting_only_pitcher?), 10) +
      top_players(days_back, baseball_players.select(&:relief_only_pitcher?), 4)
    player_average(players)
  end

  def rotowire_total(stat_type)
    baseball_players.map do |bp|
      bp.rotowire_stats.find{|st| st.stat_type == stat_type}
    end.reject(&:nil?).map do |st|
      400 - st.rank
    end.sum
  end

  def unranked_players
    baseball_players.select{|bp| bp.rotowire_stats.empty?}.map{|bp| [bp.name, bp.fantrax_stats_by_days_back(7).fantasy_ppg]}
  end
end

