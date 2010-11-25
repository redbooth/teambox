// Set the originator so we know which form opened this facebox and which form to add to
document.on('click', '.google_docs_attachment a[rel="facebox"]', function(e, link){
  google_docs_originator = link.up('.google_docs_attachment')
})

// As search results come back when filtering results add them in place of the current list
document.on('ajax:success', '#google_docs #search_form form', function(e, form) {
  form.up('#google_docs').down('#google_docs_list').replace(e.memo.responseText)
})

document.on('change', '#google_docs input[type="checkbox"]', function(e, checkbox){
  // Find the various elements we are going to interact with
  var form_area = google_docs_originator.down('.google_docs_attachment_form_area')
  var prefix = form_area.readAttribute('data-object-name')
  var previous_field = form_area.down('input')
  
  // Work out the last field number and add one to it
  var field_number = previous_field ? previous_field.readAttribute('name').findLastNumber() + 1 : 0
  
  // For each of the data attributes create a hidden field
  var fields = ['document_id', 'title', 'url', 'document_type', 'edit_url', 'acl_url']
  fields.each(function(field_name){
    var newInput = new Element('input', {
      type: 'hidden',
      name: prefix + '[google_docs_attributes][' + field_number + '][' + field_name + ']',
      value: checkbox.readAttribute('data-' + field_name.gsub('_', '-'))
    })
    
    form_area.down('.fields').insert(newInput)
  })
  
  // Add details about this document to the document list
  var title = checkbox.readAttribute('data-title') 
  var doc_type = checkbox.readAttribute('data-document-type')
  var url = checkbox.readAttribute('data-url')
  var image = '<img src="/images/google_docs/icon_6_' + doc_type + '.gif" />'
  form_area.down('.file_list').insert('<li>' + image + '<a href="' + url + '">' + title + '</li>')
  
  // Close facebox
  Prototype.Facebox.close()
})

// Find the last number in a string - adapted from increment last number as we have many fields
String.prototype.findLastNumber = function(){
  var matches = this.match(/\d+/g)
  return parseInt(matches.first())
}