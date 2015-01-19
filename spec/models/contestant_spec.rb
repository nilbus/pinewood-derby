require 'spec_helper'

describe Contestant do
  before :all do
    Faye.ensure_reactor_running!
  end

  describe '.next_suitable' do
    it 'returns an empty array when there are no contestants' do
      Contestant.delete_all
      expect(Contestant.next_suitable).to be_nil
    end

    it 'returns a contestant when a contestant exists' do
      Contestant.create! name: 'Donald Duck'
      expect(Contestant.next_suitable).not_to be_nil
    end

    it 'ignores contestants that are retired' do
      Contestant.delete_all
      Contestant.create! name: 'Donald Duck', retired: true
      expect(Contestant.next_suitable).to be_nil
    end

    it 'uses contestants that are no longer retired' do
      Contestant.delete_all
      Contestant.create! name: 'Donald Duck', retired: false
      expect(Contestant.next_suitable).not_to be_nil
    end
  end
end
