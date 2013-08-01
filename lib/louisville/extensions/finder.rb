module Louisville
  module Extensions
    module Finder

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          class << self
            alias_method_chain :relation, :louisville_finder
          end
        end
      end

      module ClassMethods
        private

        def relation_with_louisville_finder
          rel = relation_without_louisville_finder
          rel.extend RelationMethods unless rel.respond_to?(:find_one_with_louisville)
          rel
        end
      end

      module RelationMethods

        def find_one(id)

          id = id.id if ActiveRecord::Base === id

          return super(id) if louisville_config.numeric?(id)

          seq_column = "#{louisville_config[:column]}_sequence"

          if self.column_names.include?(seq_column)
            base, seq = Louisville::Util.slug_parts(id)
            record = self.where(louisville_config[:column] => base, seq_column => seq).first
          else
            record = self.where(louisville_config[:column] => id).first
          end

          return record if record

          if louisville_config.option?(:history)

            base, seq = Louisville::Util.slug_parts(id)

            joins(:historical_slugs).where("#{Louisville::Slug.quoted_table_name}.slug_base = ? AND #{Louisville::Slug.quoted_table_name}.slug_sequence = ?", base, seq).first
          else
            return super(id)
          end

        end

        def exists?(id = :none)
          id = id.id if ActiveRecord::Base === id

          return super(id) if louisville_config.numeric?(id)

          if id === String
            return true       if super(louisville_config[:column] => id)
            return super(id)  unless louisville_config.option?(:history)

            base, seq = Louisville::Util.slug_parts(id)

            historical_slugs.exists?(:slug_base => base, :slug_sequence => seq)

          elsif ActiveRecord::VERSION::MAJOR == 3
            return super(id == :none ? false : id)
          else
            return super(id)
          end


        end

      end

    end
  end
end