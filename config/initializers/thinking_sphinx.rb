if Teambox.config.allow_search or Rails.env.test? or Rails.env.cucumber?
  require 'thinking_sphinx'

  # http://github.com/freelancing-god/thinking-sphinx/issues#issue/140
  ThinkingSphinx::ActiveRecord.class_eval do
    def primary_key_for_sphinx
      read_attribute(self.class.primary_key_for_sphinx)
    end
  end

  # ThinkingSphinx.deltas_enabled = false
  # ThinkingSphinx.updates_enabled = false
else
  class ActiveRecord::Base
    def self.define_index
      # do nothing
    end
  end
end