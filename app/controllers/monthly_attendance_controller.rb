class MonthlyAttendanceController < ApplicationController
  unloadable

  before_filter :authorize_global

  include EasyAttendancesHelper
  helper :easy_attendances



end
