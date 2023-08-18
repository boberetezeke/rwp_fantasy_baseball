require_relative '../../../ruby_world_prototype/app/objects/obj'
require_relative '../../../ruby_world_prototype/app/objects/database'
require_relative '../../../ruby_world_prototype/app/objects/store'
require_relative '../../app/objects/baseball_stat_store'
require_relative '../../app/objects/rotowire_prospect_store'
require_relative '../../app/objects/baseball_player'
require_relative '../../app/objects/baseball_team'
require_relative '../../app/objects/fantasy_team'
require_relative '../../app/objects/rotowire_stat'

describe Obj::RotowireProspectStore do
  describe '#sync' do
    let(:db) { Obj::Database.new }
    subject { Obj::RotowireProspectStore.new(db, 'spec/fixtures')}

    before do
      subject.sync
    end

    it 'builds the baseball_player objects' do
      expect(db.objs[:baseball_player].size).to eq(3)
    end

    it 'builds baseball_team objects' do
      expect(db.objs[:baseball_team].size).to eq(3)
    end

    it 'builds rotowire_stat objects' do
      expect(db.objs[:baseball_player].map{|k,bp| bp.rotowire_stats.size}).to eq([1,1,1])
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
