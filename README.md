# Louisville

This is not a Swiss Army Bulldozer. This is not a Pseudocephalopod. Contrary to popular belief, this was not written in Kentucky. This is a moderately simple, moderately extensible, moderately opinionated slugging library.

## Installation

```ruby
gem 'louisville', github: 'mnelson/louisville', tag: 'vmajor.minor.path'
```

## Usage

Just need the most basic of slugging?

```ruby
add_column :players, :slug, :string
add_index  :players, :slug, unique: true
```

```ruby
class Player < ActiveRecord::Base
  include Louisville::Slugger

  slug :name
end
```


Need a litte more? The `slug` class method accepts an options hash.

| Option Key | Option Value | Default Value | What it does |
| ---------- | ------------ | ------------- | ------------ |
| :column    | Any String   | "slug"        | Configures the slug column. "slug" is the default, provide to override. |
| :finder    | true         | true          | Adds the finder extension. The finder extension allows `class.find('slug')` to work. |
| :finder    | false        | true          | Removes the finder option, disabling the `class.find` override. |
| :collision | :string_sequence | :none     | Handles collisions by appending a sequence to the slug. A generated slug which collides with an existing slug will gain a "--number". So if there was a record with "foobar" as it's slug and another record generated the slug "foobar", the second record would save as "foobar--2". |
| :collision | :numeric\_sequence | :none    | Handles collisions my incrementing a numeric column named `"#{slug\_column}\_sequence"`. With this configuration, the slug column may not be unique but the `[slug, slug\_sequence]` combination would be. |
| :setter    | Any Valid Ruby Method String | false | Allows the slug generation to be short circuited by providing a setter. Think about a user choosing their username or a page having an seo title. Collisions with the provided value will not be resolved, meaning a validation error will occur if an existing slug is provided. |
| :history   | true         | false         | When a record's slug changes this will create a record in the slugs table. The finder and collision resolver extensions respect the existence of the history table if this option is enabled.

### Collision Resolvers

Two collision resolvers are included in Louisville. You can decide which to use based on the profile of your app. If you're app is read heavy and/or rarely colliding on write, :string\_sequence is fine for you. If your app is write heavy or deals with collisions often, :numeric\_sequence is a better choice.

**collision: :numeric_sequence**

To use this collision resolver configure your schema like so:

```ruby
add_column :players, :slug, :string
add_column :players, :slug_sequence, :integer, default: 1
add_index :players, [:slug, :slug_sequence], unique: true
```

### Setter

I found this to be a shortcoming of other libraries and intended to make it dead simple to implement. Many times you want you users to be able to choose their slugs, skipping any kind of collision resolution. In Louisville it's simple:

```ruby
class Player
  slug :name, setter: :desired_slug
end
```

Now, you can simply do `player.desired_slug = params[:username]` and if available the record's slug will be set, otherwise the record will have a validation error.

### History

You'll need to create a slug table (no model) for this to work:

```ruby
create_table :slugs do |t|
  t.string   :sluggable_type
  t.integer  :sluggable_id
  t.string   :slug_base
  t.integer  :slug_sequence, :default => 1
 end
```

Now with the table created, you can change a records slug and the previous value(s) will be stored in the slugs table. Note that the current slug is not stored in the table.


## Creating your own extension

You can provide your own extension to Louisville by creating a module within the Louisville::Extensions namespace. For instance.

```ruby
module Louisville
  module Extensions
    module Upcase
      self.included(base)
        base.class_eval do
          alias_method_chain :sanitize_louisville_slug, :upcase
        end
      end

      protected

      def sanitize_louisville_slug_with_upcase(value)
        value = sanitize_louisville_slug_without_upcase(value).upcase
        value = value.gsub(/[\d]+/, '') if louisville_config.options_for(:upcase)[:remove_numbers]
        value
      end
    end
  end
end
```

Then, in your class you would do:

```ruby
class Player
  include Louisville::Slugger

  slug :name, upcase: true
  # or if you wanted to provide options for the module...
  slug :name, upcase: {remove_numbers: true}
end
```
