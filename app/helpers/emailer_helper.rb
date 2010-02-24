module EmailerHelper

  include UploadsHelper
  include TasksHelper

  def email_global
    'font-size: 14px; color: rgb(50,50,50); font-family: Helvetica, Arial'
  end

  def email_box
    'background-color: rgb(255,255,200); margin: 10px; padding: 10px; border: 1px rgb(220,220,150) solid'
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
    render :partial => 'emailer/answer'
  end

  def emailer_list_comments(comments)
    render :partial => 'emailer/comment', :collection => comments, :locals => { :unread => comments.first }
  end

  def emailer_recent_conversations(project)
    render :partial => 'emailer/recent_conversations', :locals => { :project => project }
  end

  def emailer_recent_tasks(project)
    render :partial => 'emailer/recent_tasks', :locals => { :project => project }
  end

  def emailer_answer_to_this_email
    content_tag(:p,I18n.t('emailer.notify.reply')) if APP_CONFIG['allow_incoming_email']
  end

  def tasks_for_daily_reminder(tasks, user, header)
    if tasks && tasks.any?
      render :partial => 'emailer/tasks_for_daily_reminder', :locals => { :tasks => tasks, :user => user, :header_text => header }
    end
  end

  def task_status_style(task)
    styles = []
    styles << "display: table-cell"
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

end