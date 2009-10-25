module Spec
  module Rails
    module Matchers
      def belong_to(association)
        return simple_matcher("model to belong to #{association}") do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:belongs_to).find { |a| a.name == association }
        end
      end

      def have_many(association)
        return simple_matcher("model to have many #{association}") do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:has_many).find { |a| a.name == association }
        end
      end

      def have_one(association)
        return simple_matcher("model to have one #{association}") do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:has_one).find { |a| a.name == association }
        end
      end

      def have_and_belong_to_many(association)
        return simple_matcher("model to have and belong to many #{association}") do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:has_and_belongs_to_many).find { |a| a.name == association }
        end
      end
    end
  end
end
