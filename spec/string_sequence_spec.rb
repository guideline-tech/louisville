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
    a.save.should be_true

    a.slug.should eql('charlie')
    a.slug_sequence.should eql(1)

    b = SsUser.new
    b.name = 'charlie'
    b.save.should be_true

    b.slug.should eql('charlie--2')

    c = SsUser.new
    c.name = 'charlie'
    c.save.should be_true

    c.slug.should eql('charlie--3')

    # ensures the sql matcher is working correctly
    b.reload
    b.name = 'Charlie'
    b.save

    b.slug.should eql('charlie--2')
  end

end
