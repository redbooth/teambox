class Public::ConversationsController < Public::PublicController

  def index
    @conversations = @project.conversations
  end

  def show
    load_conversation
  end

  protected

    def load_conversation
      begin
        @conversation = @project.conversations.find(params[:id])
      rescue
        flash[:error] = t('not_found.conversation', :id => params[:id])
      end
    
      redirect_to public_project_path(@project) unless @conversation
    end


end