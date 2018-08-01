Redmine::Plugin.register :redmine_monthly_attendance_report do
  name 'Redmine Monthly Attendance Report plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  menu :top_menu, 'Monthly Attendance', {:controller => 'monthly_attendance', :action => 'index' },
       :caption => 'Monthly Attendance', html: {class: 'icon icon-time'}, :if => Proc.new {
        User.current.allowed_to_globally?(:view_monthly_attendance, {})
      }

  project_module :monthly_attendance do
    permission :view_monthly_attendance, { monthly_attendance: [:index, :daily_report]}
  end

  settings :default => {
      "annual"  => 6,
      "sick"  => 8,
      "excuse"  => 7,
  }, :partial => 'monthly_attendance/settings/setting'

end
