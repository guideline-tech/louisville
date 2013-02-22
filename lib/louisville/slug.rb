module Louisville
  class Slug < ActiveRecord::Base

    belongs_to :sluggable, :polymorphic => true

    validates :sluggable_type, :sluggable_id, :slug, :presence => true
    validates :slug, :uniqueness => {:scope => [:sluggable_id, :sluggable_type]}
    
  end
end