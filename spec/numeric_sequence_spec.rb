require 'spec_helper'

describe Louisville::CollisionResolvers::NumericSequence do

  class NsUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :collision => :numeric_sequence
  end

  it 'should solve collisions by incrementing the sequence column' do
    a = NsUser.new
    a.name = 'chris'
    expect(a.save).to eq(true)

    expect(a.slug).to eq('chris')
    expect(a.slug_sequence).to eq(1)

    b = NsUser.new
    b.name = 'chris'
    expect(b.save).to eq(true)

    expect(b.slug).to eq('chris')
    expect(b.slug_sequence).to eq(2)

    c = NsUser.new
    c.name = 'chris'
    expect(c.save).to eq(true)

    expect(c.slug).to eq('chris')
    expect(c.slug_sequence).to eq(3)
  end

end
