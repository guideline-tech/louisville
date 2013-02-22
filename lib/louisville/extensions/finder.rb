module Louisville
  module Extensions
    module Finder


      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          class << self
            alias_method_chain :find_one, :louisville
            alias_method_chain :exists?, :louisville
          end
        end
      end


      module ClassMethods

        def find_one_with_louisville(id)
          id = id.id if ActiveRecord::Base === id

          return find_one_without_louisville(id) if louisville_config.numeric?(id)

          record = self.where(louisville_config.column => id).first

          if louisville_config.option?(:history)
            record ||= joins(:historical_slugs).where(:historical_slugs => {:slug => id}).first
          end

          record
        end

        def exists_with_louisville?(id)
          id = id.id if ActiveRecord::Base === id

          return exists_without_louisville?(id) if louisville_config.numeric?(id)
          return true                           if exists_without_louisville(louisville_config[:column] => id)
          
          louisville_config.option?(:history) && historical_slugs.exists?(:slug => id)
        end

      end

    end
  end
end