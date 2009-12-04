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
    '-' * 29 + '=' * 2 + '-' * 29
  end
  
  def answer_instructions
    render :partial => 'emailer/answer'
  end
  
  def emailer_list_comments(target)
    render :partial => 'emailer/comment', :collection => target.comments, :locals => { :unread => target.comments.first }
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
end