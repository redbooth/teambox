module RjsHelper
  
  def ef(e)
    page << "if($('#{e}')){"
  end

  def esf(e)
    page << "}else if($('#{e}')){"
  end

  def els
    page << "}else{"
  end

  def en
    page << "}"
  end

  def show_loading(action,id=nil)
    update_page do |page|
      if id
        page["#{action}_loading_#{id}"].show
        page.ef("#{action}_#{id}_link")
          page["#{action}_#{id}_link"].hide
        page.en
      else
        page["#{action}_loading"].show
        page.ef("#{action}_link")
          page["#{action}_link"].hide
        page.en
      end
    end
  end

  def hide_loading(action,id=nil)
    update_page do |page|
      if id
        page["#{action}_loading_#{id}"].hide
        page.ef("#{action}_#{id}_link")
          page["#{action}_#{id}_link"].show
        page.en
      else
        page["#{action}_loading"].hide
        page.ef("#{action}_link")
          page["#{action}_link"].hide
        page.en
      end
    end
  end

  def reload_javascript_events
    page << "Event.addBehavior.reload()"
  end
  
  def reload_page_sort
    page.call "Page.makeSortable"
  end

  def safe_remove_element(*ids)
    Array(ids).each do |id|
      page << "if ($('#{id}')) $('#{id}').remove();"
    end
  end

  def update_watching(project,user,target,state = :normal)
    page.replace 'watching', people_watching(project,user,target,state)
    page.delay(2) do
      page['updated_watch_state'].visual_effect :fade, :duration => 2
    end
  end

end