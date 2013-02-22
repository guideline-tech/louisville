require "louisville/version"

module Louisville
  
  autoload :Config,   'louisville/config'
  autoload :Slug,     'louisville/slug'
  autoload :Slugger,  'louisville/slugger'

  module Extensions

    autoload :Collision,  'louisville/extensions/collision'
    autoload :Finder,     'louisville/extensions/finder'
    autoload :History,    'louisville/extensions/history'
    autoload :Setter,     'louisville/extensions/setter'

  end

  module CollisionResolvers

    autoload :Abstract,         'louisville/collision_resolvers/abstract'
    autoload :None,             'louisville/collision_resolvers/none'
    autoload :NumericSequence,  'louisville/collision_resolvers/numeric_sequence'
    autoload :StringSequence,   'louisville/collision_resolvers/string_sequence'

  end

end
