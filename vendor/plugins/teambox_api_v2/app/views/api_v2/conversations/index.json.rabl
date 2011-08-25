attributes :id, :name, :simple, :comments_count, :is_private, :hidden_comments_count
collection @conversations

child(:user) { attributes :id, :first_name, :last_name }
child(:project) { attributes :id, :name, :permalink }
