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
  
  def google_docs_image(document_type)
    image_tag "/images/google_docs/icon_6_#{document_type}.gif"
  end
end
