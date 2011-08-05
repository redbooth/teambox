#Contains methods to allow you to control delivery of emails
module EmailDeliveryControl

  #Switch delivery_method to test unless we're sending out export/import emails
  class ExportImportMailInterceptor
    def self.delivering_email(mailer, template, *args)
      mailer.send(template, *args).deliver if template.to_s[/import|export/]
    end
  end

  #Within the block, will only render and deliver emails
  #related to 'import' or 'export'
  def only_import_export_emails
    Emailer.register_interceptor(ExportImportMailInterceptor)
    yield
    Emailer.unregister_interceptor
  end

end
