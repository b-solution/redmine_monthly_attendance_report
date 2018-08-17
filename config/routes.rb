# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'monthly_attendance', to: 'easy_attendances#monthly_attendance', via: [:get, :post]
match 'daily_report', to: 'easy_attendances#daily_report', via: [:get, :post]