require_relative '../../../ruby_world_prototype/app/objects.rb'
require_relative '../../../ruby_world_prototype/app/migrations.rb'
require_relative '../../../ruby_world_prototype/spec/support/database_support.rb'

require_relative '../../app/objects'
require_relative '../../app/migrations'
require_relative '../../app/migrations/add_base_classes'

require 'csv'

describe Obj::FantraxStore do
  let(:db_type_class) { Obj::DatabaseAdapter::SqliteDb }
  let(:db_test_filename) { 'test.sqlite3' }
  context 'db_type_all' do
    describe '#sync' do
      let(:db) { Obj::Database.new(database_adapter_class: db_type_class, filename: db_test_filename) }
      let(:fantrax_store) { Obj::FantraxStore.new(db, 'spec/fixtures', status_proc: ->(str){}) }
      let(:rotowire_prospect_store) { Obj::RotowireProspectStore.new(db, 'spec/fixtures', status_proc: ->(str){}) }
      let(:rotowire_dynasty_store) { Obj::RotowireDynastyStore.new(db, 'spec/fixtures', status_proc: ->(str){}) }

      let(:fantasy_players_and_stats) do
        [
          ['Blake Snell', [2,0,0]],
          ['Braxton Garrett', [2,0,0]],
          ['Corbin Carroll', [0,0,1]],
          ['Elly De La Cruz', [2,1,0]],
          ['Jesus Luzardo', [2,0,0]],
          ['Jackson Chourio', [0,1,0]],
          ['Jackson Holliday', [0,1,0]],
          ['Juan Soto', [0,0,1]],
          ['Ronald Acuna', [2,0,1]],
          ['Wyatt Langford', [0,1,0]],
        ]
      end

      let(:fantasy_teams_and_players) do
        [
          ['GG', ['Elly De La Cruz', 'Jesus Luzardo']],
          ['Loggers', ['Blake Snell']],
          ['OOLF', ['Ronald Acuna']],
          ['PB', ['Braxton Garrett']],
        ]
      end

      let(:baseball_teams_and_players) do
        [
          ['ARI', ['Corbin Carroll']],
          ['BAL', ['Jackson Holliday']],
          ['CIN', ['Elly De La Cruz']],
          ['MIA', ['Braxton Garrett', 'Jesus Luzardo']],
          ['MIL', ['Jackson Chourio']],
          ['SD', ['Blake Snell', 'Juan Soto', 'Ronald Acuna' ]],
          ['TEX', ['Wyatt Langford']],
        ]

      end

      before do
        allow(Obj::Database).to receive(:database_adapter).and_return(Obj::DatabaseAdapter::SqliteDb)
        # allow(Obj::Database).to receive(:database_adapter).and_return(Obj::DatabaseAdapter::InMemoryDb)
        db.connect
        Obj::Database.migrate(Obj::Setup.migrations, db)
        Obj::Database.migrate(Obj::FantasyBaseball::Setup.migrations, db)
        Obj::Setup.register_classes(db, Obj::Setup.classes)
        Obj::FantasyBaseball::Setup.register_classes(db, Obj::FantasyBaseball::Setup.classes)
      end

      after do
        Obj::Database.rollback(Obj::FantasyBaseball::Setup.migrations, db)
        Obj::Database.rollback(Obj::Setup.migrations, db)
      end

      shared_examples 'data after sync is correct' do
        it 'builds the baseball_player objects' do
          expect(db.objs[:baseball_player].size).to eq(10)
        end

        it 'builds fantasy_team objects' do
          expect(db.objs[:fantasy_team].size).to eq(4)
        end

        it 'has the correct fantasy teams and players' do
          fantasy_teams_and_players.each do |team_name, player_names|
            db_team = db.where_by(:fantasy_team, { name: team_name }).first
            expect(db_team).not_to be_nil
            db_player_names = db_team.baseball_players.map(&:name)
            expect(db_player_names.sort).to eq(player_names.sort)
          end
        end

        it 'has the correct baseball teams and players' do
          baseball_teams_and_players.each do |team_name, player_names|
            db_team = db.where_by(:baseball_team, { name: team_name }).first
            expect(db_team).not_to be_nil
            db_player_names = db_team.baseball_players.map(&:name)
            expect(db_player_names.sort).to eq(player_names.sort)
          end
        end

        it 'has the correct fantasy stats for players' do
          fantasy_players_and_stats.each do |player_name, stats|
            db_player = db.where_by(:baseball_player, { name: player_name }).first
            expect(db_player).not_to be_nil
            db_stats = [
              db_player.fantrax_stats.size,
              db_player.rotowire_stats.select{|rs| !rs.eta.nil?}.size,
              db_player.rotowire_stats.select{|rs| rs.eta.nil?}.size,
            ]
            expect(db_stats).to eq(stats)
          end
        end
      end

      context 'when syncing prospects/dynasty/fantrax' do
        before do
          rotowire_prospect_store.sync
          rotowire_dynasty_store.sync
          fantrax_store.sync
        end

        it_behaves_like 'data after sync is correct'
      end



      context 'when syncing fantrax/prospects/dynasty' do
        before do
          fantrax_store.sync
          rotowire_prospect_store.sync
          # rotowire_dynasty_store.sync
        end

        # it_behaves_like 'data after sync is correct'

        it 'has the correct fantasy teams and players' do
          #fantasy_teams_and_players.each do |team_name, player_names|
          player_names = ['Elly De La Cruz', 'Jesus Luzardo']
            db_team = db.find_by(:fantasy_team, { name: 'GG' })
            expect(db_team).not_to be_nil
            db_player_names = db_team.baseball_players.map(&:name)
            expect(db_player_names.sort).to eq(player_names.sort)
          #end
        end
      end

      context 'when syncing again in fantrax order' do
        before do
          fantrax_store.sync
          rotowire_prospect_store.sync
          rotowire_dynasty_store.sync
          fantrax_store.sync
          rotowire_prospect_store.sync
          rotowire_dynasty_store.sync
        end

        it_behaves_like 'data after sync is correct'
      end

      context 'when syncing again in rotowire order' do
        before do
          rotowire_prospect_store.sync
          rotowire_dynasty_store.sync
          fantrax_store.sync
          rotowire_prospect_store.sync
          rotowire_dynasty_store.sync
          fantrax_store.sync
        end

        it_behaves_like 'data after sync is correct'
      end
    end
  end
end
