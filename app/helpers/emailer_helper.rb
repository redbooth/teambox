module EmailerHelper

  include UploadsHelper
  include TasksHelper

  def email_global
    'font-size: 14px; color: rgb(50,50,50); font-family: Helvetica, Arial; margin: 20px 0'
  end

  def email_box(target = nil)
    case target
    when Task
      case target.status
      when 0 # new
        'background-color: #f5f5f5; border-bottom: 2px #cccccc solid;'
      when 2 # hold
        'background-color: #ffddff; border-bottom: 2px #bb99bb solid;'
      when 3 # resolved
        'background-color: #ddffdd; border-bottom: 2px #66aa66 solid;'
      when 4 # rejected
        'background-color: #ffdddd; border-bottom: 2px #aa6666 solid;'
      else # assigned and default
        'background-color: rgb(255,255,200); border-bottom: 2px rgb(220,220,150) solid;'
      end
    when Conversation
      'background-color: rgb(245,245,245); border-bottom: 2px rgb(200,200,200) solid;'
    when Activity
      'background-color: rgb(255,255,220); border-bottom: 2px rgb(200,200,200) solid;'
    else
      'background-color: rgb(255,255,220); border: 1px rgb(220,220,150) solid;'
    end + 'padding: 5px 10px; margin: 20px 0;'
  end

  def email_button
    "border-top: 1px solid #96D1F8; background: #65A9D7; background: -webkit-gradient(linear, left top, left bottom, from(#3E779D), to(#65A9D7)); background: -moz-linear-gradient(top, #3E779D, #65A9D7); padding: 4px 10px; -webkit-border-radius: 6px; -moz-border-radius: 6px; border-radius: 6px; -webkit-box-shadow: rgba(0, 0, 0, 1) 0 1px 0; -moz-box-shadow: rgba(0, 0, 0, 1) 0 1px 0; box-shadow: rgba(0, 0, 0, 1) 0 1px 0; text-shadow: rgba(0, 0, 0, .4) 0 1px 0; color: white; font-size: 14px; font-family: Helvetica, serif; text-decoration: none; vertical-align: middle; margin: 5px 10px;"
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

  def emailer_list_comments(comments, unread = nil )
    unread ||= comments.first
    render :partial => 'emailer/comment', :collection => comments, :locals => { :unread => unread }
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

  def task_due_on_style(task, options={})
    styles = []
    styles << "font-size: 12px"
    styles << "display: table-cell"
    styles << "color: rgb(200,0,0)" if options[:late]
    styles.join(";")
  end

  def task_style
    "font-size: 14px; font-weight: bold; color: #005; text-decoration: none;"
  end

  def task_project_style
    "font-size: 12px; color: #777; text-decoration: none;"
  end

  def email_navigation
    "order-bottom-left-radius: 5px 5px; border-bottom-right-radius: 5px 5px; border-top-left-radius: 5px 5px; border-top-right-radius: 5px 5px;padding: 4px 10px;"
  end

end
