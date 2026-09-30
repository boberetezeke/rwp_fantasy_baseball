require_relative '../../../ruby_world_prototype/app/objects.rb'
require_relative '../../../ruby_world_prototype/app/migrations.rb'
require_relative '../../../ruby_world_prototype/spec/support/database_support.rb'

require_relative '../../app/objects'
require_relative '../../app/migrations'
require_relative '../../app/migrations/add_base_classes'

require 'csv'

describe Obj::FantraxStore do
  # let(:db_type_class) { Obj::DatabaseAdapter::SqliteDb }
  # let(:db_test_filename) { 'test.sqlite3' }
  db_type_all do
    describe '#sync' do
      let(:db) { Obj::Database.new(database_adapter_class: db_type_class, filename: db_test_filename) }
      subject { Obj::FantraxStore.new(db, 'spec/fixtures')}

      before do
        # allow(Obj::Database).to receive(:database_adapter).and_return(Obj::DatabaseAdapter::SqliteDb)
        # allow(Obj::Database).to receive(:database_adapter).and_return(Obj::DatabaseAdapter::InMemoryDb)
        db.connect
        Obj::Database.migrate(Obj::Setup.migrations, db)
        Obj::Database.migrate(Obj::FantasyBaseball::Setup.migrations, db)
        Obj::Setup.register_classes(db, Obj::Setup.classes)
        Obj::FantasyBaseball::Setup.register_classes(db, Obj::FantasyBaseball::Setup.classes)

        subject.sync
      end

      after do
        Obj::Database.rollback(Obj::FantasyBaseball::Setup.migrations, db)
        Obj::Database.rollback(Obj::Setup.migrations, db)
      end

      it 'builds the baseball_player objects' do
        expect(db.objs[:baseball_player].size).to eq(5)
      end

      it 'builds fantasy_team objects' do
        expect(db.objs[:fantasy_team].size).to eq(4)
      end

      it 'builds baseball_team objects' do
        expect(db.objs[:baseball_team].size).to eq(3)
      end

      it 'builds fantrax_stat objects' do
        expect(db.objs[:baseball_player].all.map{|bp| bp.fantrax_stats.size}).to eq([2,2,2,2,2])
      end

      it 'has the correct stats in the fantrax object' do
        blake_snell = db.objs[:baseball_player].values.find{|bp| bp.name == 'Blake Snell'}
        blake_snell_stat = blake_snell.fantrax_stats.to_a.first
        expect(blake_snell_stat.fantasy_ppg).to eq(41)
        expect(blake_snell_stat.baseball_player).to eq(blake_snell)
        expect(db.objs[:fantrax_stat].values.first.baseball_player).not_to be_nil
      end
    end
  end
end
