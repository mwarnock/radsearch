# Radsearch
# Copyright (C) 2009 University of Maryland School of Medicine
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  # This is a module that loads necessary restful_authentication for every controller
  include AuthenticatedSystem
  
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
    
    if logged_in?
       session[:username] = User.find(session[:user_id]).login
    else
       access_denied
    end
   
  end

end
