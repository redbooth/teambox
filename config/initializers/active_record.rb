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

class ActiveRecord::Base

  def update_record_without_timestamping
    class << self
      def record_timestamps; false; end
    end

    save

    class << self
      remove_method :record_timestamps
    end
  end

  def update_record_without_timestamping!
    class << self
      def record_timestamps; false; end
    end

    save!

    class << self
      remove_method :record_timestamps
    end
  end

  def to_json(options = {})
    respond_to?(:to_api_hash) ? to_api_hash(options).to_json : super(options)
  end
end
