# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '280655d2ccc8da7ca570a2cfc81698d7'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
  
  def authenticate
    
    # Authentication
    #
    # Custom authentication should be implemented here.
    #
    # Radsearch expects the username to be stored in a session variable session[:username].  
    # This is used to store search terms for research and auditing purposes.

    session[:username] = "bogus"

  end

  def hipaa_filter
    # Include configuration for your own hipaa audit log here.
    # If you're using the umm hipaa log plugin, it provides the hippa_filter
    # and this can be deleted.
  end
  
end
