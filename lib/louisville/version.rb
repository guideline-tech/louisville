module Louisville
  module VERSION

    MAJOR = 0
    MINOR = 0
    PATCH = 1
    PRE = 'beta'

    def self.to_s
      [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end
  end
end
