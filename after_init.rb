ActiveSupport.on_load(:easyproject, yield: true) do
  Redmine::MenuManager.map :top_menu do |menu|
    menu.push('Other Reports', {:controller => 'monthly_attendance', :action => 'index' }, {
        :parent => :easy_attendances,
        :caption => 'Other Reports',
        :if => Proc.new { User.current.allowed_to_globally?(:view_monthly_attendance, {})},
    })
  end
end