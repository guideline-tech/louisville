require 'spec_helper'

describe "Minimal Collision Integration" do

  class MinimalCollisionUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name
  end

  it 'should ensure the slug is unique' do
    u = MinimalCollisionUser.new
    u.name = 'pete'
    expect(u.save).to eq(true)

    u2 = MinimalCollisionUser.new
    u2.name = 'pete'
    expect(u2.save).to eq(false)

    expect(u2.errors[:slug].to_s).to match(/has already been taken/)
  end

end
