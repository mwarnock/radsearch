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
      redirect_to redirect_back_or_default(root_path)
    else
      render :action => :edit
    end
  end
  
end
