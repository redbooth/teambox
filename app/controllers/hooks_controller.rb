class HooksController < ApplicationController

  no_login_required
  skip_before_filter :verify_authenticity_token

  def create
    @source = params[:hook_name]
    output = case @source
              when "github" then post_from_github
              when "email"  then post_from_email
              else 'Invalid hook'
              end

    render :text => output[0], :status => output[1]
  end
  
  protected

    def post_from_github
      return ["Invalid project", 400] unless @current_project

      push = JSON.parse(params[:payload])
      commits = push["commits"]

      text = "<h3>New code on <a href='#{push['repository']['url']}'>#{push['repository']['name']}</a> #{push['ref']}</h3>\n\n"
      text << commits[0,10].collect do |commit|
        message = commit['message'].strip.split("\n").first
        "#{commit['author']['name']} - <a href='#{commit['url']}'>#{message}</a>"
      end.join("<br/>")
      text << "<br/>And #{commits.size - 10} more commits" if commits.size > 10

      user = @current_project.user
      target = nil

      @current_project.new_comment(user, target, {
        :body => "<div class='hook_#{@source}'>#{text}</div>",
        :user => @current_project.user
      }).save!

      [RDiscount.new(text).to_html, 200]
    end

    # This code is optimized for Sendgrid's processing email: http://wiki.sendgrid.com/doku.php?id=parse_api
    # Will accept emails from webhooks, like Sendgrid's, with these parameters:
    # to:          The virtual address at Teambox. Needs to match teambox.yml settings.
    # from:        The sender of the email. This accepts any format that looks like an email.
    # text:        The email body in text format.
    # subject:     Subject line
    # attachments: Number of attachments in the email
    def post_from_email
      unless params[:from] and params[:text] and params[:subject] and params[:to]
        return ["Error processing email: Bad parameters", 400]
      end
      email = TMail::Mail.new
      email.from    = params[:from]
      email.to      = params[:to].gsub('@reply', '@app') ## server migration
      email.body    = params[:text]
      email.subject = params[:subject]
      email.body   += "\n\nThis email had #{params[:attachments]} attachments" if params[:attachments].to_i > 0
      begin
        Emailer.receive(email.to_s)
      rescue
        return ["Error processing email\n\n#{$!}", 400]
      end
      ['Email processed!', 200]
    end
end