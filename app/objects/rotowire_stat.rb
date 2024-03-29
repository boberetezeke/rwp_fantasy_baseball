class Obj::RotowireStat < Obj
  belongs_to :baseball_player, :baseball_player_id, inverse_of: :rotowire_stats

  def self.default_display
    {
      sym_sets: {
        default: [:id, :level, :at_bats, :ops, :innings_pitched, :era, :strikeouts_per_nine ]
      },
      fields: {
        id: { width: 35, type: :string, title: 'ID' },
        recorded_date: { width: 10, type: :date, title: 'Date' },
        stat_type: { width: 5, type: :string, title: 'Type' },
        rank: { width: 5, type: :integer, title: 'Rank' },
        eta: { width: 6, type: :integer, title: 'ETA' },
        year_signed: { width: 6, type: :integer, title: 'Signed' },
        level: { width: 10, type: :string, title: 'Level' },

        at_bats: { width: 5, type: :integer, title: 'AB' },
        hrs: { width: 5, type: :integer, title: 'HR' },
        runs_batted_in: { width: 5, type: :integer, title: 'RBI'},
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

  def initialize(recorded_date, stat_type, rank, eta, year_signed, level,
                 at_bats, hrs, runs_batted_in, stolen_bases, strikeout_pct, walk_pct, average, on_base_pct, slugging_pct, ops,
                 innings_pitched, earned_run_average, whip, batters_struckout, batters_walked, strikeouts_per_nine, walks_per_nine, strikeouts_per_walks)
    super(:rotowire_stat, {
      recorded_date: recorded_date,
      stat_type: stat_type,
      rank: rank,
      eta: eta,
      year_signed: year_signed,
      level: level,
      at_bats: at_bats,
      hrs: hrs,
      runs_batted_in: runs_batted_in,
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