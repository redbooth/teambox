ActiveRecord::Base.extend HtmlFormatting

ActiveRecord::Associations::AssociationCollection.class_eval do
  def new_by_user(user, attributes = {})
    new(attributes) { |obj| obj.user = user; yield(obj) if block_given? }
  end
  
  def build_by_user(user, attributes = {})
    build(attributes) { |obj| obj.user = user; yield(obj) if block_given? }
  end
  
  def create_by_user(user, attributes = {})
    create(attributes) { |obj| obj.user = user; yield(obj) if block_given? }
  end
end

ActsAsList::InstanceMethods.module_eval do
  def remove_from_list
    if in_list?
      decrement_positions_on_lower_items
      # Can cause "can't modify frozen object" error.
      # Also, it's completely unnecessary.
      # update_attribute position_column, nil
    end
  end
end

class ActiveRecord::Base
  def to_json(options = {})
    if self.methods.include? 'to_api_hash'
      to_api_hash(options).to_json
    end
  end
end
