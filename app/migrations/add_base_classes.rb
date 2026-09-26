class Obj::FantasyBaseball::AddBaseClasses
  def self.up(database)
    database.create_table(
      :fantasy_team,
      {
        name: :string,
      }
    )
    database.create_table(
      :baseball_team,
      {
        name: :string,
      }
    )
    database.create_table(
      :baseball_player,
      {
        name: :string,
        age: :integer,
        remote_id: :string,
        positions: :string,
        baseball_team_id: :integer,
        fantasy_team_id: :integer
      }
    )
    database.create_table(
      :fantrax_stat,
      {
        baseball_player_id: :integer,
        recorded_date: :datetime,
        days_back: :integer,
        fantasy_ppg: :float,
        fantasy_pts: :float,
        roster_pct: :float,
        roster_pct_chg: :float
      }
    )
    database.create_table(
      :rotowire_stat,
      {
        baseball_player_id: :integer,
        recorded_date: :datetime,
        stat_type: :string,
        rank: :integer,
        eta: :integer,
        year_signed: :integer,
        level: :string,

        at_bats: :integer,
        hrs: :integer,
        runs_batted_in: :integer,
        stolen_bases: :integer,
        strikeout_pct: :float,
        walk_pct: :float,
        average: :float,
        on_base_pct: :float,
        slugging_pct: :float,
        ops: :float,

        innings_pitched: :integer,
        earned_run_average: :float,
        whip: :float,
        batters_struckout: :integer,
        batters_walked: :integer,
        strikeouts_per_nine: :float,
        walks_per_nine: :float,
        strikeouts_per_walks: :float,
      }
    )
  end

  def self.down(database)
    database.drop_table(:fantasy_team)
    database.drop_table(:baseball_team)
    database.drop_table(:baseball_player)
    database.drop_table(:fantrax_stat)
    database.drop_table(:rotowire_stat)
  end
end
