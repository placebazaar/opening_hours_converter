require 'opening_hours_converter/constants'

module OpeningHoursConverter
  class Day
    include Constants
    attr_accessor :intervals

    def initialize
      @intervals = []
    end

    def get_as_minute_array
      minute_array = Array.new(MINUTES_MAX + 1, false)

      @intervals.each do |interval|
        if !interval.nil?
          start_minute = nil
          end_minute = nil
          off = interval.is_off

          if off
            start_minute = 0
            end_minute = MINUTES_MAX
          elsif interval.day_start == interval.day_end || interval.day_end == DAYS_MAX && interval.end == MINUTES_MAX
            start_minute = interval.start
            end_minute = interval.end
          elsif interval.day_end == interval.day_start + 1 && interval.end == 0
            start_minute = interval.start
            end_minute = MINUTES_MAX
          end

          unless start_minute.nil? && end_minute.nil?
            for minute in start_minute..end_minute
              minute_array[minute] = off ? "off" : true
            end
          else
            raise "Invalid interval #{interval.inspect}"
          end
        end
      end

      minute_array
    end

    def get_intervals(clean=false)
      if clean
        minute_array = get_as_minute_array
        intervals = []
        minute_start = -1
        minute_end = nil
        off = false

        minute_array.each_with_index do |minute, i|
          if i == 0 && minute
            off = true if minute == "off"
            minute_start = i
          elsif i == minute_array.length - 1 && minute
            intervals << OpeningHoursConverter::Interval.new(0, minute_start, 0, i - 1, off)
            minute_start = -1
            off = false
          else
            if minute && minute_start < 0
              minute_start = i
            elsif !minute && minute_start >= 0
              intervals << OpeningHoursConverter::Interval.new(0, minute_start, 0, i - 1, off)
              minute_start = -1
              off = false
            end
          end
        end
        intervals
      else
        @intervals
      end
    end

    def add_interval(interval)
      @intervals << interval
      return @intervals.length - 1
    end

    def edit_interval(id, interval)
      @intervals[id] = interval
    end

    def remove_interval(id)
      @intervals[id] = nil
    end

    def clear_intervals
      @intervals = []
    end

    def copy_intervals(intervals)
      @intervals = []
      intervals.each do |interval|
        if !interval.nil? && !interval.is_off && interval.day_start == 0 && interval.day_end == 0
          @intervals << interval.dup
        end
      end
      @intervals = get_intervals(true)
    end

    def same_as?(day)
      day.get_as_minute_array == get_as_minute_array
    end
  end
end
