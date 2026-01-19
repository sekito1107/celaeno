require 'rails_helper'

RSpec.describe TargetResolver, type: :model do
  describe '#mirror_position' do
    let(:resolver) { described_class.new(double, double) }

    it 'converts :left to :right' do
      expect(resolver.send(:mirror_position, 'left')).to eq :right
    end

    it 'converts :right to :left' do
      expect(resolver.send(:mirror_position, :right)).to eq :left
    end

    it 'converts others to :center' do
      expect(resolver.send(:mirror_position, :center)).to eq :center
      expect(resolver.send(:mirror_position, 'invalid')).to eq :center
    end

    it 'handles nil gracefully' do
      expect { resolver.send(:mirror_position, nil) }.not_to raise_error
      expect(resolver.send(:mirror_position, nil)).to eq :center
    end
  end
end
