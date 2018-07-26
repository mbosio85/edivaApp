class UsersController < ApplicationController
  
  before_filter :save_login_state, :only => [:index ]
  
  def index
    
  end


  ## create new user
  def create
    ## check signup parameter values
    if (params[:username] == "" or params[:email]=="" or params[:password]=="" or params[:password_confirmation]=="")
      redirect_to :index
      flash[:notice] = "Please fill all the requested fields"
      flash[:color]= "invalid"
      return
    elsif (params[:username] =~ /(\s)+/)
      redirect_to :index
      flash[:notice] = "You username can not contain spaces !!"
      flash[:color]= "invalid"    
      return
    elsif (params[:username] =~ /[#&@!~._%+-]+/)
      redirect_to :index
      flash[:notice] = "You username can not contain special character(s) !!"
      flash[:color]= "invalid"    
      return
    elsif (params[:username] == "test" or params[:username] == "Test" or params[:username] == "TEST")
      redirect_to :index
      flash[:notice] = "You username can not be " + params[:username] + " !! Try another username please !!"
      flash[:color]= "invalid"    
      return
    elsif (! (params[:email] =~ /[A-Za-z0-9._%+-]+\@[A-Za-z0-9.-]+\.[A-Za-z]/)) ## initial check for valid email address format
      redirect_to :index
      flash[:notice] = "Not a valid email format !"
      flash[:color]= "invalid"
      return
    elsif (params[:password].length < 6)
      redirect_to :index
      flash[:notice] = "Password too short !"
      flash[:color]= "invalid"
      return
    elsif (params[:password].length > 20)
      redirect_to :index
      flash[:notice] = "Password too long !"
      flash[:color]= "invalid"      
      return
    elsif (params[:password] != params[:password_confirmation]) ## checking for password and password confirmation match
      redirect_to :index
      flash[:notice] = "Password and password confirmation mismatch ! Please re-enter it "
      flash[:color]= "invalid"
      return
    else
      @msg = User.createSubmituser(params[:username],params[:email],params[:password])
    end
    
   if (@msg == "email")
      redirect_to :index
      flash[:notice] = "Email already exists in the database ! If you have forgotten your password contact eDiVa team !!"
      flash[:color]= "invalid"
      return
    elsif (@msg == "user")
      redirect_to :index
      flash[:notice] = "Username already taken ! Try a different one !!"
      flash[:color]= "invalid"
      return
    elsif (@msg == "success")
      redirect_to :index
      flash[:notice] = "Successfully new user has been created ! Please login to get started with eDiVa !!"
      flash[:color]= "valid"
      return
    else
      flash[:notice] = "Some error happened,please try again "+@msg
      flash[:color]= "invalid"
    end    

  end

  def authenticateUser
    valmsg = User.validateUser(params[:login_username],params[:login_password])
    if (valmsg == 'validuser')
      session[:user] = params[:login_username]
      redirect_to :controller => 'aapp', :action => 'analysis'
      #flash[:notice] = "Login correct !!"
      #flash[:color]= "valid"
    else
      redirect_to :index
      flash[:notice] = "Username & password mismatch ! Please try again !!"
      flash[:color]= "invalid"
    end
  end
  
  def logout     
    session[:user] = nil
    redirect_to :index
  end

def reset_pwd
  valmsg = User.reset_password(params[:email])
  if (valmsg != 'invaliduser') 
    
    redirect_to :index
    flash[:notice] = "Mail sent with a new password" 
    flash[:color] = "valid"
  else
      redirect_to :index
      flash[:notice] = "Mail sent with a new password"
      flash[:color]= "invalid"  
    end
end

end




