require 'spec_helper'

describe SingleValue do
  describe '.update, .get' do
    it 'persists a hash' do
      hash = {'somekey' => 'value'}
      SingleValue.update hash
      expect(SingleValue.get).to eq hash
    end

    it 'is scoped to the subclass' do
      hash1 = {'somekey' => 'value'}
      hash2 = {'anotherkey' => 'anothervalue'}
      SingleValue.update hash1
      class SingleValueSubclass < SingleValue; end
      SingleValueSubclass.update hash2
      expect(SingleValue.get).to eq hash1
      expect(SingleValueSubclass.get).to eq hash2
    end
  end

  describe '.get' do
    it 'takes a :newer_than option to limit the results' do
      SingleValue.update when: 'just now'
      expect(SingleValue.get newer_than: 1.second.ago).not_to be_nil
      expect(SingleValue.get newer_than: Time.now).to be_nil
    end
  end
end
