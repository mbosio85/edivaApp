class AappController < ApplicationController

  before_filter :authenticate_user, :only => [:analysis]

  def analysis
    @wspace = Analysis.gWorkspace(session[:user])
  end

  def annotate
     
  end


  def actionAnnotate
    workspace = nil
    @wspace = Analysis.gWorkspace(session[:user])
    
    if @wspace == nil
      workspace = nil
    else
      @wspace.each do |r1|
        workspace = r1
      end
    end
    
    if workspace == nil
      redirect_to :annotate
      flash[:notice] = "You need to select a main project before proceeding with the analysis !"
      flash[:color]= "invalid"
    else  
      ## handle user input file for variants
      #userVcf = params[:vcf].original_filename
      @msg = Corelib.handleUserFile(params[:vcf],session[:user],workspace)
      if @msg == "upload"
        flash[:notice] = "VCF file uplaoded"
        flash[:color]= "valid"
        redirect_to :analysis        
      end
    end
  end



  def createProject
    ## check parameter values
    if (params[:project] == "")
      redirect_to :analysis
      flash[:notice] = "Invalid project name !"
      flash[:color]= "invalid"
    else
      @msg = Analysis.cProject(params[:project],session[:user], params[:mainProject])
    end
    
    if @msg == "project"
      redirect_to :analysis
      flash[:notice] = "Project already exists ! Provide a different name please !!"
      flash[:color]= "invalid"
      return
    end
      redirect_to :analysis
      flash[:notice] = "Project created !!"
      flash[:color]= "valid"  
  end    



end
