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

    u.save.should be_true

    u.slug.should eql('carljr')

  end

  it 'should not attempt to uniquify if the desired slug is provided' do

    u = SetterUser.new
    u.name = 'carey'
    u.save.should be_true

    u2 = SetterUser.new
    u2.name = 'kerry'
    u2.desired_slug = 'carey'

    u2.save.should be_false

    u2.errors[:slug].to_s.should =~ /has already been taken/

  end

end