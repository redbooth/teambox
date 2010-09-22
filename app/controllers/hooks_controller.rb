class HooksController < ApplicationController

  no_login_required
  skip_before_filter :verify_authenticity_token

  def create
    @source = params[:hook_name]
    output = case @source
              when "github"  then post_from_github
              when "email"   then post_from_email
              when "pivotal" then post_from_pivotal
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

      @current_project.conversations.new_by_user(user, :body => "<div class='hook_#{@source}'>#{text}</div>", :simple => true ).save!

      [RDiscount.new(text).to_html, 200]
    end

    def post_from_pivotal
      return ["Invalid project", 400] unless @current_project
      return ["No activity", 400] unless activity = params[:activity]
      return ["No story found on this activity, skipping", 400] unless activity[:stories] && activity[:stories][:story][:id]

      story = activity[:stories][:story]
      author = @current_project.users.detect { |u| u.name == activity[:author] }
      task_list = @current_project.task_lists.find_by_name("Pivotal Tracker") ||
                  @current_project.task_lists.new.tap do |tl|
                    tl.user = author || @current_project.user
                    tl.name = "Pivotal Tracker"
                    tl.save!
                  end
      task = task_list.tasks.find(:first, :conditions => ['name LIKE ?', "%[PT#{story[:id]}]%"]) ||
             task_list.tasks.new.tap do |t|
               t.name = "#{story[:name]} [PT#{story[:id]}]"
               t.project = @current_project
               t.user = author || @current_project.user
               t.save!
             end

      body = case activity[:event_type]
      when 'story_create'
        "#{story[:description]}\n\n<a href='#{story[:url]}'>View on #PT</a>"
      when 'story_update'
        # this is called when description is updated or status changes (start, finish, etc)
        if story[:current_state]
          if author
            "I marked the task as #{story[:current_state]} on #PT"
          else
            "#{activity[:author]} marked the task as #{story[:current_state]} on #PT"
          end
        elsif story[:description]
          "Task description is now: #{story[:description]} #PT"
        else
          "#{activity[:description]} #PT"
        end
      when 'story_delete'
        # story_delete should mark it as rejected
        if author
          "I deleted this activity on #PT"
        else
          "#{activity[:author]} deleted this activity on #PT"
        end
      when 'note_create'
        if author
          "#{story[:notes][:note][:text]} #PT"
        else
          "#{activity[:author]} commented on #PT: '#{story[:notes][:note][:text]}'"
        end
      else
        "#{activity[:description]} #PT"
      end

      @current_project.new_comment(author || @current_project.user, task, {:body => body}).save!
      [RDiscount.new(body).to_html, 200]
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
      email.to      = params[:to]
      email.cc      = params[:cc]
      email.body    = strip_responses(params[:text])
      email.subject = params[:subject]
      
      email.body   += "\n\nThis email had #{params[:attachments]} attachments" if params[:attachments].to_i > 0
      begin
        Emailer.receive(email.to_s)
      rescue
        return ["Error processing email\n\n#{$!}", 400]
      end
      ['Email processed!', 200]
    end
    
    def strip_responses(body)
      # For GMail. Matches "On 19 August 2010 13:48, User <proj+conversation+22245@app.teambox.com<proj%2Bconversation%2B22245@app.teambox.com>> wrote:"
      body.strip.gsub(/\n[^\r\n]*\d{2,4}.*\+.*\d@app.teambox.com.*:.*\z/m, '').strip
    end
end