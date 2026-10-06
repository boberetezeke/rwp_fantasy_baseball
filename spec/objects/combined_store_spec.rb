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

      before do
        allow(Obj::Database).to receive(:database_adapter).and_return(Obj::DatabaseAdapter::SqliteDb)
        # allow(Obj::Database).to receive(:database_adapter).and_return(Obj::DatabaseAdapter::InMemoryDb)
        db.connect
        Obj::Database.migrate(Obj::Setup.migrations, db)
        Obj::Database.migrate(Obj::FantasyBaseball::Setup.migrations, db)
        Obj::Setup.register_classes(db, Obj::Setup.classes)
        Obj::FantasyBaseball::Setup.register_classes(db, Obj::FantasyBaseball::Setup.classes)

        fantrax_store.sync
        rotowire_prospect_store.sync
        rotowire_dynasty_store.sync
      end

      after do
        Obj::Database.rollback(Obj::FantasyBaseball::Setup.migrations, db)
        Obj::Database.rollback(Obj::Setup.migrations, db)
      end

      it 'builds the baseball_player objects' do
        expect(db.objs[:baseball_player].size).to eq(10)
      end

      it 'doesnt add more baseball_player objects on a re-sync' do
        fantrax_store.sync
        rotowire_prospect_store.sync
        rotowire_dynasty_store.sync
        expect(db.objs[:baseball_player].size).to eq(10)
      end

      it 'builds fantasy_team objects' do
        expect(db.objs[:fantasy_team].size).to eq(4)
      end

      it 'doesnt add more fantasy_team objects on a re-sync' do
        subject.sync
        expect(db.objs[:fantasy_team].size).to eq(4)
      end
    end
  end
end
