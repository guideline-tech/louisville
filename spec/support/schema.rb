ActiveRecord::Schema.define(:version => 20130628161227) do

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "slug"
    t.integer  "slug_sequence",                         :default => 1
    t.string   "other_slug"
    t.integer   "other_slug_sequence",                   :default => 1
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "slugs", :force => true do |t|
    t.string   "sluggable_type"
    t.integer  "sluggable_id"
    t.string   "slug_base"
    t.integer  "slug_sequence",                         :default => 1
  end
end
