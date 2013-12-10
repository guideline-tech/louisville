require 'spec_helper'

describe Louisville::Extensions::Finder do

  class FinderUser < ActiveRecord::Base
    self.table_name = :users

    include Louisville::Slugger

    slug :name, finder: true
  end

  class FindeerUser < FinderUser

  end

  class FinderHistoryUser < ActiveRecord::Base
    self.table_name = :users
    include Louisville::Slugger

    slug :name, finder: true, history: true
  end

  class Slug < ActiveRecord::Base
    self.table_name = :slugs
  end

  it 'should allow a model to be found via its slug' do
    f = FinderUser.new
    f.name = 'harold'
    f.save.should be_true

    FinderUser.find('harold').should eql(f)
  end

  it 'should blow up when nothing can be found' do
    lambda{
      FinderUser.find('dajlsflj290rjodsals')
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'should be fine with inhertance' do
    f = FindeerUser.new
    f.name = 'harmon'
    f.save.should be_true

    FindeerUser.find('harmon').should eql(f)
  end

  it 'should raise an error with history enabled' do
    f = FinderHistoryUser.new
    f.name = 'harold'
    f.save.should be_true

    f.reload
    f.name = 'harry'
    f.save.should be_true

    f.slug.should eql('harry')
    Slug.where(sluggable_type: 'FinderHistoryUser', sluggable_id: f.id).count.should eql(1)

    FinderHistoryUser.find('harry').should eql(f)
    FinderHistoryUser.find('harold').should eql(f)

    lambda{
      FinderHistoryUser.find('harvey')
    }.should raise_error(ActiveRecord::RecordNotFound)
  end


end
