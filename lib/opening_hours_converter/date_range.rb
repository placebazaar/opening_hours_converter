module OpeningHoursConverter
  class DateRange
    attr_accessor :wide_interval, :typical, :comment

    def initialize(wide_interval = nil)
      @wide_interval = nil
      @typical = nil
      @comment = ''
      update_range(wide_interval)
    end

    def defines_typical_day?
      @typical.instance_of?(OpeningHoursConverter::Day)
    end

    def defines_typical_week?
      @typical.instance_of?(OpeningHoursConverter::Week)
    end

    def update_range(wide_interval)
      @wide_interval = !wide_interval.nil? ? wide_interval : OpeningHoursConverter::WideInterval.new.always

      return unless @typical.nil?

      @typical = case @wide_interval.type
                 when 'day'
                   if @wide_interval.end.nil?
                     OpeningHoursConverter::Day.new
                   else
                     OpeningHoursConverter::Week.new
                   end
                 else
                   OpeningHoursConverter::Week.new
                 end
    end

    def add_comment(comment = '')
      @comment += comment if comment
    end

    def has_same_typical?(date_range)
      defines_typical_day? == date_range.defines_typical_day? && @typical.same_as?(date_range.typical)
    end

    def is_general_for?(date_range)
      defines_typical_day? == date_range.defines_typical_day? && @wide_interval.contains?(date_range.wide_interval) && @comment == date_range.comment
    end

    def is_holiday?
      result = @wide_interval.type == 'holiday'
      if !result
        @typical.intervals.each do |i|
          if !i.nil?
            result = true if i.day_start == -2 && i.day_end == -2
          end
        end
      end
      result
    end
  end
end
