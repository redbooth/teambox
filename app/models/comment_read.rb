class CommentRead < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true
  set_table_name "comments_read"
  
  named_scope :user, lambda { |user| { :conditions => { :user_id => user.id } } } do
    def unread_count(target)
      user_id = self.new.user_id
      
      last_comment = self.last_read_comment(target)

      if target.last_comment_id.nil?
        return 0
      else
        if last_comment.nil?
          target.comments.count
        else
          target.comments.count(:conditions => 
            [ "id > ?", last_comment.last_read_comment_id ] )
        end
      end
    end
    
    def read_up_to(comment,project = false)
      if project
        CommentRead.delete_all({
          :target_type => 'Project',
          :target_id => comment.project_id
        })

        cr = self.new({
          :target_type => 'Project',
          :target_id => comment.project_id,
          :last_read_comment_id => comment.id
        })
      else
        CommentRead.delete_all({
          :target_type => comment.target_type,
          :target_id => comment.target_id
        })

        cr = self.new({
          :target_type => comment.target_type,
          :target_id => comment.target_id,
          :last_read_comment_id => comment.id
        })
      end
      
      cr.save
    end
    
    def are_comments_read?(target)
      last_read_comment = self.last_read_comment(target)
      
      unless last_read_comment.nil?
        
        if target.last_comment_id.nil? or last_read_comment.id >= target.last_comment_id
          return false
        else
          return true
        end
        
      else
        if target.last_comment_id.nil?
          return true
        else
          return false
        end
      end
    end
    
    def last_read_comment(target)
      CommentRead.find(:first,
        :conditions => {
          :target_type => target.class.name,
          :target_id => target.id },
        :limit => 1)
    end
  end
end