class SearchController < ApplicationController

  before_filter :permission_to_search

  def index
  end

  protected

    def permission_to_search
      unless current_user.can_search?
        flash[:notice] = "Search is disabled"
        redirect_to root_path
      end
    end
end
