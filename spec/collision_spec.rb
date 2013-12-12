require 'spec_helper'

describe Louisville::Extensions::Collision do

  class MinimalCollisionUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :collision => :none
  end

  class MinimalCollisionSequenceUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :collision => :string_sequence, :setter => true

  end

  let(:mcu) { MinimalCollisionUser.new }
  let(:mcsu) { MinimalCollisionSequenceUser.new }
  let(:resolver) {
    mcsu.send(:louisville_collision_resolver)
  }

  it 'should ensure the slug is unique' do
    mcu.name = 'pete'
    expect(mcu.save).to eq(true)

    u2 = MinimalCollisionUser.new
    u2.name = 'pete'
    expect(u2.save).to eq(false)

    expect(u2.errors[:slug].to_s).to match(/has already been taken/)
  end

  it 'should choose a collision resolver based on the config' do
    expect(resolver).to be_a(Louisville::CollisionResolvers::StringSequence)
  end

  it 'should override the slug reader to read from the resolver' do
    expect(resolver).to receive(:read_slug).once
    mcsu.louisville_slug
  end

  it 'should override the slug writer to apply via the resolver' do
    expect(resolver).to receive(:assign_slug).with('test').once
    mcsu.send(:louisville_slug=, 'test')
  end

  context "#should_uniquify_louisville_slug?" do

    it 'should not uniquify if the resolver does not provide a solution' do
      resolver = double(:provides_collision_solution? => false)
      allow(mcu).to receive(:louisville_collision_resolver){ resolver }
      allow(mcu).to receive(:louisville_slug_changed?){ true }
      expect(mcu.send(:should_uniquify_louisville_slug?)).to eq(false)
    end

    it 'should uniquify if the resolver provides a solution' do
      resolver = double(:provides_collision_solution? => true)
      allow(mcu).to receive(:louisville_collision_resolver){ resolver }
      allow(mcu).to receive(:louisville_slug_changed?){ true }
      expect(mcu.send(:should_uniquify_louisville_slug?)).to eq(true)
    end

    it 'should not uniquify if the setter extension is used and present' do
      allow(mcsu).to receive(:louisville_slug_changed?){ true }
      expect(mcsu.send(:should_uniquify_louisville_slug?)).to eq(true)
      mcsu.desired_slug = 'test'
      expect(mcsu.send(:should_uniquify_louisville_slug?)).to eq(false)
    end

  end

end
