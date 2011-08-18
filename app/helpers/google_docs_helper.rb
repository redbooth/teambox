module GoogleDocsHelper
  def google_docs_checkbox_tag(item, index)
    check_box_tag "document_#{index}", item[:id], false,
      'data-document-id' => item[:document_id],
      'data-title' => item[:title],
      'data-url' => item[:url],
      'data-document-type' => item[:document_type],
      'data-edit-url' => item[:edit_url],
      'data-acl-url' => item[:acl_url]
  end

  def google_docs_enabled?
    Teambox.config.providers? and
    Teambox.config.providers.detect { |p| p.provider == 'google' }
  end

  def hide_google_docs_if_not_configured
    %(<style type='text/css'>
        form .google_docs_attachment { display: none }
      </style>).html_safe unless google_docs_enabled?
  end

  def google_docs_image(document_type)
    image_tag "/images/google_docs/icon_6_#{document_type}.gif"
  end

  def google_docs_write_access_link(google_doc)
    access = google_doc.write_lock? ? :unlock : :lock
    link_to t("google_docs.google_doc.#{access.to_s}"), write_access_project_google_doc_path(:project_id => google_doc.project, :id => google_doc, :access => access), :method => :put, :remote => true, :class => "google_doc_write_lock"
  end

end
