require 'rspec/expectations'

module RSpec
  module Rails
    module Matchers

      RSpec::Matchers.define :belong_to do |association|
        match do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:belongs_to).find { |a| a.name == association }
        end
        description do
          "model to belong to #{association}"
        end
      end

      RSpec::Matchers.define :have_many do |association|
        match do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:has_many).find { |a| a.name == association }
        end
        description do
          "model to have many #{association}"
        end
      end

      RSpec::Matchers.define :have_one do |association|
        match do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:has_one).find { |a| a.name == association }
        end
        description do
          "model to have one #{association}"
        end
      end

      RSpec::Matchers.define :have_and_belong_to_many do |association|
        match do |model|
          model = model.class if model.is_a? ActiveRecord::Base
          model.reflect_on_all_associations(:has_and_belongs_to_many).find { |a| a.name == association }
        end
        description do
          "model to have and belong to many #{association}"
        end
      end

    end
  end
end
