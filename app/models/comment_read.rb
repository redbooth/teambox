class CommentRead < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true
  belongs_to :last_read_comment, :class_name => 'Comment'
  set_table_name "comments_read"
  
  named_scope :user, lambda { |user| { :conditions => { :user_id => user.id } } } do
    def unread_count(target)
      if target.last_comment_id.nil?
        return 0
      else
        last_comment = self.last_read_comment(target)
        
        if last_comment.nil?
          last_id = 0
        else
          last_id = last_comment.last_read_comment_id
        end
        
        target.comments.count(:conditions => 
        [ "id > ? AND target_type = ? AND target_id = ?",
          last_id, target.class.name, target.id])
        
      end
    end
    
    def read_up_to(comment,project = false)
      if project
        delete_all({
          :target_type => 'Project',
          :target_id => comment.project_id
        })

        cr = self.new({
          :target_type => 'Project',
          :target_id => comment.project_id,
          :last_read_comment_id => comment.id
        })
      else
        delete_all({
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
      if target.comments.length == 0
        return true
      end
      last_comment = self.last_read_comment(target)
      
      unless last_comment.nil?
        
        if target.last_comment_id.nil? or last_comment.last_read_comment_id < target.last_comment_id
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
    
    def unread?(comment)
      @@time_cache ||= {}
      comment = Comment.find(comment.id)
      target = comment.target
      
      @@time_cache["#{target.class.name}"] ||= []
      
      if @@time_cache["#{target.class.name}"][target.id].nil?
        last_read = last_read_comment(target)
        if last_read
          @@time_cache["#{target.class.name}"][target.id] = last_read.last_read_comment.created_at
        else
          @@time_cache["#{target.class.name}"][target.id] = DateTime.new(0)
        end
      end

      @@time_cache["#{target.class.name}"][target.id] < comment.created_at
    end
    
    def last_read_comment(target)
      find(:first,
        :conditions => {
          :target_type => target.class.name,
          :target_id => target.id },
        :limit => 1)
    end
  end
end