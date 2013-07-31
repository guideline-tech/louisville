require 'spec_helper'

describe 'Louisville::Slugger minimal history integration' do

  class MinimalHistoryUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :history => true
  end

  it 'should validate that the slug is present' do
    u = MinimalHistoryUser.new
    u.save.should be_false

    u.errors[:slug].to_s.should =~ /presen/
  end

  it 'should push the previous slug into the history if it changes' do
    u = MinimalHistoryUser.new
    u.name = 'joe'
    u.save.should be_true

    lambda{
      u.name = 'joey'
      u.save.should be_true
    }.should change(Louisville::Slug, :count).by(1)

    u.slug.should eql('joey')
    history = Louisville::Slug.last

    history.sluggable_type.should eql('MinimalHistoryUser')
    history.sluggable_id.should eql(u.id)

    history.slug_base.should eql('joe')
    history.slug_sequence.should eql(1)
  end

  it 'should delete the slug from the history if it is reassigned' do
    u = MinimalHistoryUser.new
    u.name = 'phil'
    u.save.should be_true

    u.name = 'philip'
    u.save.should be_true

    u.slug.should eql('philip')

    history = Louisville::Slug.last

    history.sluggable.should eql(u)

    u.name = 'phil'
    u.save.should be_true

    history2 = Louisville::Slug.last

    Louisville::Slug.where(id: history.id).exists?.should be_false
    history2.slug_base.should eql('philip')
  end

  it 'should validate that the slug is unique' do
    u = MinimalHistoryUser.new
    u.name = 'pete'
    u.save.should be_true

    u.name = 'peter'
    u.save.should be_true
    u.slug.should eql('peter')

    u2 = MinimalHistoryUser.new
    u2.name = 'pete'
    u2.save.should be_false

    u2.errors[:slug].to_s.should =~ /unique/
  end

  it 'should provide a way to find a user via the slug' do
    u = MinimalHistoryUser.new
    u.name = 'james'
    u.save.should be_true

    MinimalHistoryUser.find('james').should eql(u)

    u.name = 'jams'
    u.save.should be_true

    MinimalHistoryUser.find('jams').should eql(u)
    MinimalHistoryUser.find('james').should eql(u)

  end



end