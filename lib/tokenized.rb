module Tokenized

  def self.included(base)
    base.before_validation :generate_token, :on => :create, :unless => lambda {self.token.present?}
  end

  private

  def generate_token
    self.token = Digest::SHA512.hexdigest([Time.now, rand, self.object_id].join)[0...16]
    generate_token if self.class.exists_by_token(self.token)
  end

end