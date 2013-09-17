require 'spec_helper'

describe 'Louisville::Slugger variations' do

  class ColumnVariationUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :column => :other_slug, :history => true
  end

  it 'should use the provided column as the storage location' do
    u = ColumnVariationUser.new
    u.name = 'bob'
    u.save.should be_true

    u.slug.should be_nil
    u.other_slug.should eql('bob')
    u.other_slug_sequence.should eql(1)
  end


  it 'should not impact the history columns' do
    u = ColumnVariationUser.new
    u.name = 'bill'
    u.save.should be_true

    u.name = 'billy'
    u.save.should be_true

    history = Louisville::Slug.last

    history.slug_base.should eql('bill')
    history.slug_sequence.should eql(1)

    ColumnVariationUser.find('billy').should eql(u)
    ColumnVariationUser.find('bill').should eql(u)
  end
end
