module Louisville
  class Slug < ActiveRecord::Base
    self.table_name = :slugs

    validates :sluggable_type, :sluggable_id, :slug_base, :slug_sequence, :presence => true
    validates :slug_base, :uniqueness => {:scope => [:sluggable_id, :sluggable_type, :slug_sequence]}
  end
end
