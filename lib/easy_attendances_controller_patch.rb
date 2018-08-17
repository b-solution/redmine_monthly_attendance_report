module EasyAttendancesControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do

        # alias_method_chain :easy_attandance_tabs, :monthly

    end

  end

  module InstanceMethods
    def daily_report
      @user = if User.current.allowed_to_globally?(:view_others_attendance, {})
                User.find_by_id( params[:user_id])
              else
                User.current
              end
      @date_from = Date.parse("#{params[:date_from]}".gsub(' ', '/')) rescue Date.today
    end

    def monthly_attendance
      if request.post?
        @user = if User.current.allowed_to_globally?(:view_others_attendance, {})
                  User.find_by_id( params[:user_id])
                else
                  User.current
                end
        @date_from = Date.parse("#{params[:date_from]}".gsub(' ', '/')) rescue Date.today
        @date_to = Date.parse("#{params[:date_to]}".gsub(' ', '/')) rescue Date.today

        if @user && @date_from && @date_to
          @hash  = {}
          setting = Setting.plugin_redmine_monthly_attendance_report
          leave =  EasyAttendanceActivity.find_by_id(setting['annual']).id
          excuse =  EasyAttendanceActivity.find_by_id(setting['excuse']).id
          sick =  EasyAttendanceActivity.find_by_id(setting['sick']).id
          begin_date = @date_from
          while begin_date < @date_to

            @hash[begin_date] = []
            time = TimeEntry.where(user_id: @user.id).where(spent_on: begin_date).sum(:hours).round(2)
            @hash[begin_date]<< time


            scope =  EasyAttendance.where(user_id: @user.id).between(begin_date, begin_date).where(approval_status: EasyAttendance::APPROVAL_APPROVED)
            @hash[begin_date]<< scope.where(easy_attendance_activity_id: leave).map{|a| ((a.departure - a.arrival).to_i/3600).to_i}.sum
            @hash[begin_date]<< scope.where(easy_attendance_activity_id: sick).map{|a|  ((a.departure - a.arrival).to_i/3600).to_i}.sum
            @hash[begin_date]<< scope.where(easy_attendance_activity_id: excuse).map{|a|  ((a.departure - a.arrival).to_i/3600).to_i}.sum
            approved =  EasyAttendance.where(easy_attendance_activity_id: [sick, leave, excuse]).where(user_id: @user.id).where(approval_status: EasyAttendance::APPROVAL_APPROVED).
                between(begin_date, begin_date).map{|a|  ((a.departure - a.arrival).to_i/3600).to_i}.sum
            @hash[begin_date]<< (approved + time)
            a = (EasyUserWorkingTimeCalendar.where(user_id: @user.id) ||  EasyUserWorkingTimeCalendar.where(:is_default=> true)).last

            if EasyUserTimeCalendarHoliday.where(holiday_date: begin_date ).present? or !a.working_week_days.map{|d| d == 7 ? 0 : d }.include?(begin_date.wday)
              @hash[begin_date]<< 0
              @hash[begin_date]<< 0
            else
              @hash[begin_date]<< a.default_working_hours
              @hash[begin_date]<< (a.default_working_hours - 1).round(2)
            end

            if (approved + time) > @hash[begin_date][5]
              @hash[begin_date]<< ((approved + time) - @hash[begin_date][5] ).round(2)
            elsif (approved + time) < @hash[begin_date][6]
              @hash[begin_date]<< ((approved + time) - @hash[begin_date][5] ).round(2)
            else
              @hash[begin_date]<< 0
            end
            begin_date += 1.day
          end
        end
      end
    end
  end
end
