module RedmineAccessControl
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class << self
        alias_method_chain :available_project_modules, :kpi
      end
    end

  end

  module ClassMethods
    def available_project_modules_with_kpi
      @available_project_modules ||= available_project_modules_without_kpi
      @available_project_modules.reject!{|a| a == :monthly_attendance}
      @available_project_modules.reject!{|a| a == :KPIs}
      @available_project_modules
    end
  end
end
