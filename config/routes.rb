# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'monthly_attendance', to: 'monthly_attendance#index', via: [:get, :post]
match 'daily_report', to: 'monthly_attendance#daily_report', via: [:get, :post]