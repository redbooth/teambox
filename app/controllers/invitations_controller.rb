class InvitationsController < ApplicationController
  def index
    @invitations = @current_user.invitations
  end

  def new
    @invitation = @current_project.invitations.new
  end
  
  def create
    @invitation = @current_project.invitations.new(params[:invitation])
    if @invitation.save
      @recipient = params[:email]
      Emailer.deliver_invitation(@recipient,@current_project,@invitation)
    end
  end
end