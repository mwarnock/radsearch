# Include hook code here
ActionController::Base.send(:extend, HipaaLog::ControllerFilters)
