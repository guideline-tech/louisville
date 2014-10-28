require 'spec_helper'

describe Louisville::Slugger do

  class MinimalUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name
  end

  let(:config){ MinimalUser.louisville_config }

  it 'should assume the appropriate defaults' do
    expect(config[:field]).to     eq(:name)
    expect(config[:column]).to    eq(:slug)
    expect(config[:collision]).to eq(:none)
    expect(config[:finder]).to    eq(true)
    expect(config[:history]).to   eq(false)
  end

  it 'should wrap the field with louisville accessors' do
    u = MinimalUser.new
    u.send(:louisville_slug=, 'test')

    expect(u.slug).to eq('test')
    expect(u.louisville_slug).to eq('test')
  end

  it 'should validate that the slug is present' do
    u = MinimalUser.new
    expect(u.save).to eq(false)

    expect(u.errors[:slug].to_s).to match(/be blank/)
  end

  it 'should validate that the slug is unique by default' do
    u = MinimalUser.new
    u.name = 'john'
    expect(u.save).to eq(true)

    u2 = MinimalUser.new
    u2.name = 'john'
    expect(u2.save).to eq(false)

    expect(u2.errors[:slug].to_s).to match(/has already been taken/)
  end

  it 'should provide a way to find a user via the slug' do
    u = MinimalUser.new
    u.name = 'frank'
    expect(u.save).to eq(true)

    expect(MinimalUser.find('frank')).to eq(u)
  end

  it 'should not apply the slug if the field value changes but the slug base does not' do
    u = MinimalUser.new
    u.name = 'spencer'
    expect(u.save).to eq(true)

    u.name = 'Spencer'
    expect(u).to be_changed

    expect(u).to receive(:louisville_slug=).never
    expect(u.save).to eq(true)
  end

  it 'should only validate when the slug changes or the record is not persisted' do
    u = MinimalUser.new
    u.name = 'daniel'
    expect(u.save).to eq(true)

    u.email = 'd@test.com'
    expect(u.send(:needs_to_validate_louisville_slug?)).to eq(false)

    u.name = 'danny'
    u.send(:apply_louisville_slug) # this normally happens before validation
    expect(u.send(:needs_to_validate_louisville_slug?)).to eq(true)

    u2 = MinimalUser.new
    expect(u2.send(:needs_to_validate_louisville_slug?)).to eq(true)

    expect(u2.save).to eq(false)
    expect(u2.errors[:slug].to_s).to match(/blank/)
  end

end
