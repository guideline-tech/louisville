require 'spec_helper'

describe Louisville::Extensions::History do

  class MinimalHistoryUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :history => true
  end

  it 'should validate that the slug is present' do
    u = MinimalHistoryUser.new
    expect(u.save).to eq(false)

    expect(u.errors[:slug].to_s).to match(/be blank/)
  end

  it 'should push the previous slug into the history if it changes' do
    u = MinimalHistoryUser.new
    u.name = 'joe'

    expect{
      expect(u.save).to eq(true)
    }.not_to change(Louisville::Slug, :count)

    u.name = 'joey'
    expect{
      expect(u.save).to eq(true)
    }.to change(Louisville::Slug, :count).by(1)

    expect(u.slug).to eq('joey')
    history = Louisville::Slug.last

    expect(history.sluggable_type).to eq('MinimalHistoryUser')
    expect(history.sluggable_id).to eq(u.id)

    expect(history.slug_base).to eq('joe')
    expect(history.slug_sequence).to eq(1)
  end

  it 'should delete the slug from the history if it is reassigned' do
    u = MinimalHistoryUser.new
    u.name = 'phil'
    expect(u.save).to eq(true)

    u.name = 'philip'
    expect(u.save).to eq(true)

    expect(u.slug).to eq('philip')

    history = Louisville::Slug.last

    expect(history.sluggable_type).to eq(u.class.name)
    expect(history.sluggable_id).to eq(u.id)

    u.name = 'phil'
    expect(u.save).to eq(true)

    history2 = Louisville::Slug.last

    expect(Louisville::Slug.where(:id => history.id).exists?).to eq(false)
    expect(history2.slug_base).to eq('philip')
  end

  it 'should provide a way to find a user via the slug' do
    u = MinimalHistoryUser.new
    u.name = 'james'
    expect(u.save).to eq(true)

    expect(MinimalHistoryUser.find('james')).to eq(u)

    u.name = 'jams'
    expect(u.save).to eq(true)

    expect(MinimalHistoryUser.find('jams')).to eq(u)
    expect(MinimalHistoryUser.find('james')).to eq(u)

  end

  it 'should destroy the slugs when a record is destroyed' do
    u = MinimalHistoryUser.new
    u.name = 'jackford'
    expect(u.save).to eq(true)

    u.name = 'jackson'
    expect{
      expect(u.save).to eq(true)
    }.to change(Louisville::Slug, :count).by(1)

    expect{
      u.destroy
    }.to change(Louisville::Slug, :count).by(-1)
  end
end
