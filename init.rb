Redmine::Plugin.register :redmine_monthly_attendance_report do
  name 'Redmine Monthly Attendance Report plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.3'

  project_module :monthly_attendance do
    permission :view_own_attendance, { monthly_attendance: [:index, :daily_report]}
    permission :view_others_attendance, { monthly_attendance: [:index, :daily_report]}
  end

  settings :default => {
      "annual"  => 6,
      "sick"  => 8,
      "excuse"  => 7,
  }, :partial => 'monthly_attendance/settings/setting'

end

Rails.application.config.to_prepare do
  Redmine::AccessControl.send(:include, RedmineAccessControl)
end

