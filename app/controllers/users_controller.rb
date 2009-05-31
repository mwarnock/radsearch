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
  before_filter :requires_admin, :only => [:index, :new, :create, :destroy]
  
  def requires_admin
  end
  
  # GET - displays all users
  def index
    @users = User.find(:all)
  end
  
  # This will hold a link to the list of users
  def admin
    
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
    login = @user.login
    @user.destroy
    flash[:notice] = "Account #{login} deleted."
    redirect_to users_path
  end
  
  def edit
    @user = @current_user
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
