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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.s

class UsersController < ApplicationController
  before_filter :requires_admin, :except => [:edit, :update]
  before_filter :can_edit_self, :only => [:edit, :update]
  
  def requires_admin
    # Admin is required for every action except user password changes
    # Which use the edit and update actions
    
    # Make sure only admin can edit other users.
    if session[:username] != "admin"
      flash[:notice] = "Only admin can manage users."
      redirect_back_or_default('/search')
    end
  end
  
  def can_edit_self
    # Redirect to requires_admin if a non-admin user tries to edit another user.
    if session[:user_name] != "admin" && session[:user_id].to_s != params[:id]
      flash[:notice] = "Cannot edit other users."
      redirect_back_or_default('/search')
    end
  end
  
  # GET - displays all users
  def index
    @users = User.find(:all)
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      redirect_back_or_default('/users')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    unless @user.login == "admin"
      login = @user.login
      @user.destroy
      flash[:notice] = "Account #{login} deleted."
    else
      flash[:notice] = "Cannot delete admin account"
    end
    redirect_to users_path
  end
  
  def edit
    # Get user object based on parameters passed by browser
    @user = User.find(params[:id])
  end
  
  def update
    
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to :controller => :search, :action => :index
    else
      render :action => :edit
    end
  end
  
end
