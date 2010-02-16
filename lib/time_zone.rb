module TimeZone
  def time_zones_with_time(hour)
    ActiveSupport::TimeZone.zones_with_time_diff_to_utc(hour - Time.zone.now.hour + Time.zone.utc_offset / 3600)
  end
end