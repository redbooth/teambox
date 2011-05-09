class User

  def stats
    settings['stats'] || {}
  end

  def increment_stat(key, inc=1)
    save_stats stats.merge({ key => stats[key].to_i + inc })
  end

  def set_stat(key, value)
    save_stats stats.merge({ key => value })
  end

  def get_stat(key)
    stats[key] || 0
  end

  private

    def save_stats hash
      write_setting 'stats', hash
    end

end
