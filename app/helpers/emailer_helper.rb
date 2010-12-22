module EmailerHelper

  include UploadsHelper
  include TasksHelper

  def email_global
    'font-size: 14px; color: rgb(50,50,50); font-family: Helvetica, Arial'
  end

  def email_box(target = nil)
    case target
    when Task
      case target.status
      when 0 # new
        'background-color: #f5f5f5; border: 1px #cccccc solid;'
      when 2 # hold
        'background-color: #ffddff; border: 1px #bb99bb solid;'
      when 3 # resolved
        'background-color: #ddffdd; border: 1px #66aa66 solid;'
      when 4 # rejected
        'background-color: #ffdddd; border: 1px #aa6666 solid;'
      else # assigned and default
        'background-color: rgb(255,255,200); border: 1px rgb(220,220,150) solid;'
      end
    else
      'background-color: rgb(255,255,200); border: 1px rgb(220,220,150) solid;'
    end + 'margin: 10px; padding: 10px'
  end

  def email_text(size)
    case size
    when :small then 'font-size: 10px; color: rgb(100,100,100);'
    when :normal then 'font-size: 14px; color: rgb(50,50,50);'
    when :big   then 'font-size: 18px; color: rgb(0,0,0);'
    end
  end

  def email_answer_line
    Emailer::ANSWER_LINE
  end

  def answer_instructions
    render 'emailer/answer'
  end

  def dont_answer
    render 'emailer/dont_answer'
  end

  def emailer_list_comments(comments)
    render :partial => 'emailer/comment', :collection => comments, :locals => { :unread => comments.first }
  end

  def emailer_recent_tasks(project, user)
    recent_tasks = project.tasks.unarchived.
                    assigned_to(user).
                    sort { |a,b| (a.due_on || 1.year.ago) <=> (a.due_on || 1.year.ago)}
    render 'emailer/recent_tasks', :project => project, :recent_tasks => recent_tasks
  end

  def emailer_answer_to_this_email
    content_tag(:p,I18n.t('emailer.notify.reply')) if Teambox.config.allow_incoming_email
  end

  def emailer_commands_for_tasks(user)
    if Teambox.config.allow_incoming_email
      content_tag(:p,I18n.t('emailer.notify.task_commands', :username => user.login))
    end
  end

  def tasks_for_daily_reminder(tasks, user, header)
    if tasks && tasks.any?
      render 'emailer/tasks_for_daily_reminder', :tasks => tasks, :user => user, :header_text => header
    end
  end

  def task_status_style(task)
    styles = []
    styles << "display: inline"
    styles << "border-radius: 4px"
    styles << "font-size: 11px"
    styles << "color: white"
    styles << "width: 23px"
    styles << "text-align: center"
    bg_color = case task.status_name
      when "new"
        "rgb(170,170,170)"
      when "open"
        "rgb(50,50,250)"
      when "hold"
        "rgb(130,0,193)"
      when "resolved"
        "rgb(0,200,0)"
      when "rejected"
        "rgb(200,0,0)"
      end
    styles << "background-color:#{bg_color}"
    styles.join(";")
  end

  def task_due_on_style(task)
    styles = []
    # styles << "font-size: 11px"
    styles << "display: table-cell"
    styles << "color: rgb(200,0,0)"
    styles.join(";")
  end

  def email_navigation
    "#{organization_header_bar_colour}order-bottom-left-radius: 5px 5px; border-bottom-right-radius: 5px 5px; border-top-left-radius: 5px 5px; border-top-right-radius: 5px 5px;padding: 4px 10px;"
  end

  def inline_organization_link_colour
    "color: ##{@organization ? @organization.settings['colours']['links'] : ''}"
  end

  def inline_organization_text_colour
    "font-color: ##{@organization ? @organization.settings['colours']['text'] : ''}"
  end

end
