class MonthlyAttendanceController < ApplicationController
  unloadable

  before_action :authorize_global

  def daily_report
    @user = if User.current.allowed_to_globally?(:view_others_attendance, {})
              User.find_by_id( params[:user_id])
            else
              User.current
            end
    @date_from = Date.parse("#{params[:date_from]}".gsub(' ', '/')) rescue Date.today
  end

  def index
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
        time_record_compensation =  EasyAttendanceActivity.find_by_id(setting['time_record_compensation']).id
        begin_date = @date_from
        while begin_date <= @date_to

          @hash[begin_date] = []
          time = TimeEntry.where(user_id: @user.id).where(spent_on: begin_date).sum(:hours).round(2)
          # Recorded hours
          # 0
          @hash[begin_date]<< time


          scope =  EasyAttendance.where(user_id: @user.id).between(begin_date, begin_date).where(approval_status: EasyAttendance::APPROVAL_APPROVED)

          # Leaves
          # 1
          @hash[begin_date]<< scope.where(easy_attendance_activity_id: leave).map{|a| ((a.departure - a.arrival).to_i/3600).to_f}.sum

          # 2
          @hash[begin_date]<< scope.where(easy_attendance_activity_id: sick).map{|a|  ((a.departure - a.arrival).to_i/3600).to_f}.sum

          # 3
          @hash[begin_date]<< scope.where(easy_attendance_activity_id: excuse).map{|a|  ((a.departure - a.arrival).to_i/3600).to_f}.sum

          # 4
          @hash[begin_date]<< scope.where(easy_attendance_activity_id: time_record_compensation).map{|a|  ((a.departure - a.arrival).to_i/3600).to_f}.sum

          approved =  EasyAttendance.where(easy_attendance_activity_id: [sick, leave, excuse, time_record_compensation]).
              where(user_id: @user.id).where(approval_status: EasyAttendance::APPROVAL_APPROVED).
              between(begin_date, begin_date).map{|a|  ((a.departure - a.arrival).to_i/3600).to_f}.sum

          # Total approved hours
          # 5
          @hash[begin_date]<< (approved + time).to_f.round(2)
          a = (EasyUserWorkingTimeCalendar.where(user_id: @user.id) ||  EasyUserWorkingTimeCalendar.where(:is_default=> true)).last

          # Daily working hours (5) + min daily productivity (6)
          if EasyUserTimeCalendarHoliday.where(holiday_date: begin_date ).present? or !a.working_week_days.map{|d| d == 7 ? 0 : d }.include?(begin_date.wday)

            # 6
            @hash[begin_date]<< 0

            # 7
            @hash[begin_date]<< 0
          else
            @hash[begin_date]<< a.default_working_hours
            @hash[begin_date]<< (a.default_working_hours - 1).round(2)
          end

          # Non approved hours (7)
          if @hash[begin_date][4].to_f >= @hash[begin_date][5]

            # 8
            @hash[begin_date]<< (@hash[begin_date][5].to_f - @hash[begin_date][7] ).round(2)
          elsif @hash[begin_date][4].to_f < @hash[begin_date][6]
            @hash[begin_date]<< (@hash[begin_date][5].to_f - @hash[begin_date][7] ).round(2)
          else
            @hash[begin_date]<< 0
          end
          begin_date += 1.day
        end
      end
    end
  end
end
