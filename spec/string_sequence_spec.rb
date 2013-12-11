require 'spec_helper'

describe Louisville::CollisionResolvers::StringSequence do

  class SsUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :collision => :string_sequence
  end

  it 'should solve collisions by appending the sequence to the slug' do
    a = SsUser.new
    a.name = 'charlie'
    expect(a.save).to eq(true)

    expect(a.slug).to eq('charlie')
    expect(a.slug_sequence).to eq(1)

    b = SsUser.new
    b.name = 'charlie'
    expect(b.save).to eq(true)

    expect(b.slug).to eq('charlie--2')

    c = SsUser.new
    c.name = 'charlie'
    expect(c.save).to eq(true)

    expect(c.slug).to eq('charlie--3')

    # ensures the sql matcher is working correctly
    b.reload
    b.name = 'Charlie'
    b.save

    expect(b.slug).to eq('charlie--2')
  end

end
