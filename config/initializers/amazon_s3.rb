if Teambox.config.amazon_s3
  Paperclip::Attachment.default_options.update(
    :storage => :s3,
    :s3_credentials => Rails.root + 'config/amazon_s3.yml'
  )
end
