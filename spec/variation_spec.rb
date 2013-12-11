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
    expect(u.save).to eq(true)

    expect(u.slug).to eq(nil)
    expect(u.other_slug).to eq('bob')
    expect(u.other_slug_sequence).to eq(1)
  end


  it 'should not impact the history columns' do
    u = ColumnVariationUser.new
    u.name = 'bill'
    expect(u.save).to eq(true)

    u.name = 'billy'
    expect(u.save).to eq(true)

    history = Louisville::Slug.last

    expect(history.slug_base).to eq('bill')
    expect(history.slug_sequence).to eq(1)

    expect(ColumnVariationUser.find('billy')).to eq(u)
    expect(ColumnVariationUser.find('bill')).to eq(u)
  end
end
