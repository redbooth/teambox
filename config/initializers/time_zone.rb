module ActiveSupport
  class TimeZone
    def self.zones_with_time_diff_to_utc(time_diff)
      time_diff *= 3600 if time_diff.abs <= 13
      all.select { |z| z.utc_offset == time_diff.to_i }
    end
  end
end