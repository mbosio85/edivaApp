class AappController < ApplicationController

  before_filter :authenticate_user, :only => [:analysis]

  def analysis
    (@wspace,count) = Analysis.gWorkspace(session[:user])
    (projects,pros_number) = Analysis.gProjects(session[:user])
    
    if (pros_number == 0)
     @pros = Array.new
    else
      @pros = Array.new(pros_number)
      if projects != nil
        projects.each do |p|
          @pros.push(p)
        end
      end      
    end
    
    @files = Array.new
    
    if (count == 0)
      @wspace = nil
    else
      @wspace.each do |r1|
      Dir.foreach(session[:user] + "/" + r1) do |file|
        next if file == '.' or file == '..'
          @files.push(file)
        end
      end     
      
    end
    @actions = ['Choose action','Download','Delete']    
  end

  def annotate
     
  end


  def actionAnnotate
    workspace = nil
    @wspace,count = Analysis.gWorkspace(session[:user])
    
    if count == 0
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
        flash[:notice] = "VCF file uplaoded and annotated"
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
    else
      redirect_to :analysis
      flash[:notice] = "Project created !!"
      flash[:color]= "valid"  
    end
  end    

  def changeMainProject
    @msg = Analysis.swapWorkspace(params[:mainProjecttoSet],session[:user])

    if @msg == "change"
      redirect_to :analysis
      flash[:notice] = "Main project has been changed !!"
      flash[:color]= "valid"
      return
    else
      redirect_to :analysis
      flash[:notice] = "Something went wrong !!"
      flash[:color]= "invalid"  
    end
  end

  def workspaceFileAction     
  end

end
