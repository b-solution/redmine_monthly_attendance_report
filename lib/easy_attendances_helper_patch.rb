module EasyAttendancesHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do

        alias_method_chain :easy_attandance_tabs, :monthly

    end

  end

  module InstanceMethods
    def easy_attandance_tabs_with_monthly
      tabs = easy_attandance_tabs_without_monthly
      tabs <<  {name: 'monthly', partial: 'monthly', label: :label_monthly_attendance, redirect_link: true, url: monthly_attendance_path(tab: 'monthly')}
      tabs <<  {name: 'daily', partial: 'daily_report', label: :label_daily_report, redirect_link: true, url: daily_report_path(tab: 'daily')}
      tabs
    end
  end
end
