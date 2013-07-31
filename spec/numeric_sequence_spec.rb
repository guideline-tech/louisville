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
    a.save.should be_true

    a.slug.should eql('chris')
    a.slug_sequence.should eql(1)

    b = NsUser.new
    b.name = 'chris'
    b.save.should be_true

    b.slug.should eql('chris')
    b.slug_sequence.should eql(2)

    c = NsUser.new
    c.name = 'chris'
    c.save.should be_true

    c.slug.should eql('chris')
    c.slug_sequence.should eql(3)
  end

end