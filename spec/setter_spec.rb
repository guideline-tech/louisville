require 'spec_helper'

describe Louisville::Extensions::Setter do

  class SetterUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, :setter => true, :collision => :string_sequence

  end

  it 'should provide setters for the desired slug' do

    u = SetterUser.new
    u.name = 'carl'
    u.desired_slug = 'carljr'

    expect(u.save).to eq(true)

    expect(u.slug).to eq('carljr')

  end

  it 'should not attempt to uniquify if the desired slug is provided' do

    u = SetterUser.new
    u.name = 'carey'
    expect(u.save).to eq(true)

    u2 = SetterUser.new
    u2.name = 'kerry'
    u2.desired_slug = 'carey'

    expect(u2.save).to eq(false)

    expect(u2.errors[:slug].to_s).to match(/has already been taken/)

  end

end
