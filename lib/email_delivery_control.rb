module Mail

  #Unregister a Mail interceptor
  def self.unregister_interceptor(interceptor)
    interceptors = self.send :class_variable_get, '@@delivery_interceptors'
    interceptors.reject! do |interc|
      interc == interceptor
    end
  end

end

#Contains methods to allow you to control delivery of emails
module EmailDeliveryControl

  #Switch delivery_method to test unless we're sending out import emails
  class ImportMailInterceptor
    def self.delivering_email(message)
      message.delivery_method(:test) unless message.subject[/#{I18n.t(emailer.teamboxdata.import)}/i]
    end
  end

  #Allows you to temporarily disable sending of emails
  #despite a mailer's #deliver method being called
  #
  # 'disable' means the delivery method is set to 'test'
  def without_emails(logger=Rails.logger, &block)
    Mail.register_interceptor(ImportMailInterceptor)
    block.call
    Mail.unregister_interceptor(ImportMailInterceptor)
    logger.info "[Mail::TestMailer] #{Mail::TestMailer.deliveries.length} emails were NOT delivered!" if logger
    Mail::TestMailer.deliveries.clear
  end

end
