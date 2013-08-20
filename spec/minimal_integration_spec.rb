require 'spec_helper'

describe 'Louisville::Slugger minimal integration' do

  class MinimalUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name
  end

  let(:config){ MinimalUser.louisville_config }

  it 'should assume the appropriate defaults' do
    config[:field].should eql(:name)
    config[:column].should eql(:slug)
    config[:collision].should eql(:none)
    config[:finder].should eql(true)
    config[:history].should eql(false)
  end

  it 'should wrap the field with louisville accessors' do
    u = MinimalUser.new
    u.send(:louisville_slug=, 'test')

    u.slug.should eql('test')
    u.louisville_slug.should eql('test')
  end

  it 'should validate that the slug is present' do
    u = MinimalUser.new
    u.save.should be_false

    u.errors[:slug].to_s.should =~ /be blank/
  end

  it 'should validate that the slug is unique' do
    u = MinimalUser.new
    u.name = 'john'
    u.save.should be_true

    u2 = MinimalUser.new
    u2.name = 'john'
    u2.save.should be_false

    u2.errors[:slug].to_s.should =~ /has already been taken/
  end

  it 'should provide a way to find a user via the slug' do
    u = MinimalUser.new
    u.name = 'frank'
    u.save.should be_true

    MinimalUser.find('frank').should eql(u)
  end

end