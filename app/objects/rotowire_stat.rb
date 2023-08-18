class Obj::RotowireStat < Obj
  def self.default_display
    {
      sym_sets: {
        default: [:id, :level, :at_bats, :ops, :innings_pitched, :era, :strikeouts_per_nine ]
      },
      fields: {
        id: { width: 35, type: :string, title: 'ID' },
        rank: { width: 5, type: :integer, title: 'Rank' },
        stat_type: { width: 5, type: :string, title: 'Type' },
        eta: { width: 10, type: :string, title: 'ETA' },
        level: { width: 10, type: :string, title: 'Level' },

        at_bats: { width: 5, type: :integer, title: 'AB' },
        hrs: { width: 5, type: :integer, title: 'HR' },
        stolen_bases: { width: 5, type: :integer, title: 'SB' },
        strikeout_pct: { width: 5, type: :float, format: "%.3f", title: 'K%' },
        walk_pct: { width: 5, type: :float, format: "%.3f", title: 'BB%' },
        average: { width: 5, type: :float, format: "%.3f", title: 'AVG' },
        on_base_pct: { width: 5, type: :float, format: "%.3f", title: 'OBP' },
        slugging_pct: { width: 5, type: :float, format: "%.3f", title: 'SLG' },
        ops: { width: 5, type: :float, format: "%.3f", title: 'OPS' },

        innings_pitched: { width: 5, type: :integer, title: 'IP' },
        earned_run_average: { width: 5, type: :float, format: "%.3f", title: 'ERA' },
        whip: { width: 5, type: :float, format: "%.3f", title: 'ERA' },
        batters_struckout: { width: 5, type: :integer, title: 'K%' },
        batters_walked: { width: 5, type: :integer, title: 'BB%' },
        strikeouts_per_nine: { width: 5, type: :float, format: "%.3f", title: 'K/9' },
        walks_per_nine: { width: 5, type: :float, format: "%.3f", title: 'BB/9' },
        strikeouts_per_walks: { width: 5, type: :float, format: "%.3f", title: 'K/BB' },
      }
    }
  end

  def initialize(date, stat_type, rank, eta, level,
                 at_bats, hrs, stolen_bases, strikeout_pct, walk_pct, average, on_base_pct, slugging_pct, ops,
                 innings_pitched, earned_run_average, whip, batters_struckout, batters_walked, strikeouts_per_nine, walks_per_nine, strikeouts_per_walks)
    super(:rotowire_stat, {
      date: date,
      stat_type: stat_type,
      rank: rank,
      eta: eta,
      level: level,
      at_bats: at_bats,
      hrs: hrs,
      stolen_bases: stolen_bases,
      strikeout_pct: strikeout_pct,
      walk_pct: walk_pct,
      average: average,
      on_base_pct: on_base_pct,
      slugging_pct: slugging_pct,
      ops: ops,
      innings_pitched: innings_pitched,
      earned_run_average: earned_run_average,
      whip: whip,
      batters_struckout: batters_struckout,
      batters_walked: batters_walked,
      strikeouts_per_nine: strikeouts_per_nine,
      walks_per_nine: walks_per_nine,
      strikeouts_per_walks: strikeouts_per_walks
    })
  end
end