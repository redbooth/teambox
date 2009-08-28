module DividersHelper
  def divider_fields(f)
    render :partial => "page_dividers/fields", :locals => { :f => f }
  end
end