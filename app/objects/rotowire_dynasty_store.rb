require 'csv'

class Obj::RotowireDynastyStore < Obj::RotowireStatStore
  def sync
    Dir["#{@directory}/*"].each do|fn|
      m = /Rotowire-(\d+)-(\d+)-(\d+)--dynasty/.match(fn)
      next unless m

      date = Date.new(m[1].to_i, m[2].to_i, m[3].to_i)

      data = File.readlines(fn)
      data_without_first_line = data[1..-1].join("\n")
      lines = CSV.parse(data_without_first_line, headers: true)
      baseball_players = lines[1..-1].map do |row|
        name = row['Player']
        next if name.nil?

        rank = row['Rank'].to_i
        team = row['Team']
        position = row['Pos']
        age = row['Age'].to_i
        level = row['Level']
        at_bats = row['AB'].to_i
        hrs = row['HR'].to_i
        runs_batted_in = row['RBI'].to_i
        stolen_bases = row['SB'].to_i
        average = row['AVG'].to_f
        on_base_pct = row['OBP'].to_f
        slugging_pct = row['SLG'].to_f
        ops = row['OPS'].to_f
        innings_pitched = row['IP'].to_i
        earned_run_average = row['ERA'].to_f
        whip = row['WHIP'].to_f
        batters_struckout = row['K'].to_i
        batters_walked = row['BB'].to_i
        strikeouts_per_nine = row['K/9'].to_f
        walks_per_nine = row['BB/9'].to_f
        strikeouts_per_walks = row['K/BB'].to_f
        player = Obj::BaseballPlayer.from_csv(nil, name, team, position, nil, age)
        rotowire_prospect_stat = Obj::RotowireStat.new(
          date, 'dynasty', rank, nil, nil, level,
          at_bats, hrs, runs_batted_in, stolen_bases, nil, nil, average, on_base_pct, slugging_pct, ops,
          innings_pitched, earned_run_average, whip, batters_struckout, batters_walked, strikeouts_per_nine, walks_per_nine, strikeouts_per_walks)
        player.rotowire_stats = [rotowire_prospect_stat]
        player
      end.reject(&:nil?)

      create_baseball_players(baseball_players)
    end
    nil
  end
end
