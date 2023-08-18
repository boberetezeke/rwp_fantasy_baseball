class Obj::BaseballPlayer < Obj
  belongs_to :baseball_team, :baseball_team_id, inverse_of: :baseball_players
  belongs_to :fantasy_team, :fantasy_team_id, inverse_of: :baseball_players
  has_many :fantrax_stats, :fantrax_stat, :baseball_player_id, inverse_of: :baseball_player
  has_many :rotowire_stats, :rotowire_stat, :baseball_player_id, inverse_of: :baseball_player

  def self.default_display
    {
      sym_sets: {
        default: [:id,
                  :name,
                  { fppg: [:fantrax_stat, :fantasy_ppg] },
                  { fpts: [:fantrax_stat, :fantasy_pts] },
                  { fteam: [:fantasy_team, :name] }
        ]
      },
      fields: {
        id: { width: 35, type: :string, title: 'ID' },
        name: { width: 20, type: :string, title: 'name' }
      }
    }
  end

  def initialize(remote_id, name, positions, age)
    super(:baseball_player, {
      remote_id: remote_id,
      name: name,
      positions: positions,
      age: age,
    })
  end

  def starting_pitcher?
    positions.include?('SP')
  end

  def relief_pitcher?
    positions.include?('RP')
  end

  def starting_only_pitcher?
    positions == ['SP']
  end

  def relief_only_pitcher?
    positions == ['RP']
  end

  def hitter?
    (positions & ['C', '1B', '2B', '3B', 'SS', 'LF', 'RF', 'CF']).size > 0
  end

  def fantrax_stats_by_days_back(days_back)
    fantrax_stats.select{|fs| fs.days_back == days_back}.first
  end

  def self.from_csv(remote_id, name, team_name, positions, status, age)
    remote_id = remote_id
    name = name
    if team_name != "(N/A)"
      baseball_team = Obj::BaseballTeam.new(team_name)
      # baseball_team = db.find_by(:baseball_team, name: team_name) || db.add_obj(Obj::BaseballTeam.new(team_name))
    else
      baseball_team = nil
    end
    positions = positions&.split(/,/) || []
    if status != "FA"
      # fantasy_team = db.find_by(:fantasy_team, name: status) || db.add_obj(Obj::FantasyTeam.new(status))
      fantasy_team = Obj::FantasyTeam.new(status)
    else
      fantasy_team = nil
    end
    age = age.to_i
    player = new(remote_id, name, positions, age)
    player.baseball_team = baseball_team
    player.fantasy_team = fantasy_team
    player
  end
end
