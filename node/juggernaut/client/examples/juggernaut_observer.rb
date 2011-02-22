class JuggernautObserver < ActiveRecord::Observer
  observe :activity, :user
  
  def after_create(rec)
    publish(:create, rec)
  end
  
  def after_update(rec)
    publish(:update, rec)
  end
  
  def after_destroy(rec)
    publish(:destroy, rec)
  end
  
  protected
    def publish(type, rec)
      Juggernaut.publish(
        Array(rec.sync_clients).map {|c| "/sync/#{c}" }, 
        {:type => type, :id => rec.id, 
         :klass => rec.class.name, :record => rec}
      )
    end
end