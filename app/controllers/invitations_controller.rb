class InvitationsController < ApplicationController
  def new
    @invitation = @current_project.invitations.new
  end
  
  def create
    @invitation = @current_project.invitations.new(params[:invitation])
    if @invitation.save
      @recipient = params[:email]
      Email.deliver_invitation(@recipient,@current_project,@invitation)
    end
  end
end