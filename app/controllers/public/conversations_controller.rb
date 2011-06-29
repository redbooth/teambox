class Public::ConversationsController < Public::PublicController

  def index
    @conversations = @project.conversations.not_simple.where(:is_private => false)
  end

  def show
    load_conversation
  end

  protected

    def load_conversation
      begin
        @conversation = @project.conversations.find(params[:id])
        throw Exception.new('Private conversation') if @conversation.is_private
      rescue
        flash[:error] = t('not_found.conversation', :id => params[:id])
      end
    
      redirect_to public_project_path(@project) unless @conversation
    end


end