module GoogleDocsHelper
  def google_docs_checkbox_tag(item, index)
    check_box_tag "document_#{index}", item[:id], false,
      'data-document-id' => item[:id],
      'data-title' => item[:title],
      'data-url' => item[:link],
      'data-document-type' => item[:type],
      'data-edit-url' => item[:edit_link],
      'data-acl-url' => item[:acl_link]
  end
  
  def google_docs_image(document_type)
    image_tag "/images/google_docs/icon_6_#{document_type}.gif"
  end
end
