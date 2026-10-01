require_relative '../../../ruby_world_prototype/app/objects.rb'
require_relative '../../../ruby_world_prototype/app/migrations.rb'
require_relative '../../../ruby_world_prototype/spec/support/database_support.rb'

require_relative '../../app/objects'
require_relative '../../app/migrations'
require_relative '../../app/migrations/add_base_classes'

require 'csv'

describe Obj::RotowireProspectStore do
  # let(:db_type_class) { Obj::DatabaseAdapter::SqliteDb }
  # let(:db_test_filename) { 'test.sqlite3' }
  db_type_all do
    describe '#sync' do
      let(:db) { Obj::Database.new(database_adapter_class: db_type_class, filename: db_test_filename) }
      subject { Obj::RotowireProspectStore.new(db, 'spec/fixtures', status_proc: -> (_str) { }) }

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
        expect(db.objs[:baseball_player].size).to eq(3)
      end

      it 'builds baseball_team objects' do
        expect(db.objs[:baseball_team].size).to eq(3)
      end

      it 'builds rotowire_stat objects' do
        expect(db.objs[:baseball_player].all.map{|bp| bp.rotowire_stats.size}).to eq([1,1,1])
      end

      it 'has the correct stats in the rotowire object' do
        jackson_holliday = db.objs[:baseball_player].values.find{|bp| bp.name == 'Jackson Holliday'}
        jackson_holliday_stat = jackson_holliday.rotowire_stats.to_a.first
        expect(jackson_holliday_stat.recorded_date).to eq(Date.new(2023,1,1))
        expect(jackson_holliday_stat.rank).to eq(1)
        expect(jackson_holliday_stat.average).to eq(0.378)
        expect(jackson_holliday_stat.baseball_player).to eq(jackson_holliday)
        expect(db.objs[:rotowire_stat].values.first.baseball_player).not_to be_nil
      end
    end
  end
end
