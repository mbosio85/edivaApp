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
    @actions = ['Preview','Download','Delete']    
  end

  def annotate
     
  end

  def rank
    (@wspace,count) = Analysis.gWorkspace(session[:user])
    @files = Array.new
    
    if (count == 0)
      @wspace = nil
    else
      @wspace.each do |r1|
      Dir.foreach(session[:user] + "/" + r1) do |file|
        next if file == '.' or file == '..'
          if file =~ /annotated$/
            @files.push(file)
          end
        end
      end      
    end
    
  end

  def familyanalysis
    @inhTypes = ['denovo','dominant','recessive']
    (@wspace,count) = Analysis.gWorkspace(session[:user])
    @files = Array.new
    
    if (count == 0)
      @wspace = nil
    else
      @wspace.each do |r1|
      Dir.foreach(session[:user] + "/" + r1) do |file|
        next if file == '.' or file == '..'
          if file =~ /annotated$/
            @files.push(file)
          end
        end
      end      
    end
  end

  def actionFamilySeparate

    curProject = nil
    (@wspace,count) = Analysis.gWorkspace(session[:user])
    if (count == 0)
      curProject = nil
    else
      @wspace.each do |project|
        curProject = project  
      end
    end


    if (params[:sample1] == '' or params[:sample2] == '' or params[:sample3] == '')
      redirect_to :familyanalysis
      flash[:notice] = "Sample ID(s) cant be empty !!"
      flash[:color]= "invalid"
      return
    else
      @msg = Corelib.familyActionsSeparate(params[:sample1],params[:sample2],params[:sample3],params[:vcf1],params[:vcf2],params[:vcf3],params[:selectedFile1],params[:selectedFile2],params[:selectedFile3],params[:affected1],params[:affected2],params[:affected3],params[:inheritenceType],session[:user],curProject)
    end

    if @msg == "analysis"
      redirect_to :analysis
      flash[:notice] = "Analysis has started and the output files will available shortly !"
      flash[:color]= "valid"        
    else
      redirect_to :analysis
      flash[:notice] = @msg
      flash[:color]= "invalid"        
    end
  end

  def actionFamilyMerged
    curProject = nil
    (@wspace,count) = Analysis.gWorkspace(session[:user])
    if (count == 0)
      curProject = nil
    else
      @wspace.each do |project|
        curProject = project  
      end
    end
    
    if (params[:sample1] == '' or params[:sample2] == '' or params[:sample3] == '')
      redirect_to :familyanalysis
      flash[:notice] = "Sample ID(s) cant be empty !!"
      flash[:color]= "invalid"
      return
    else
      @msg = Corelib.familyActionsMerged(params[:sample1],params[:sample2],params[:sample3],params[:affected1],params[:affected2],params[:affected3],params[:vcfMerged],params[:selectedFileMerged],params[:inheritenceType],session[:user],curProject)
    end

    if @msg == "analysis"
      redirect_to :analysis
      flash[:notice] = "Analysis has started and the output files will available shortly !"
      flash[:color]= "valid"
      return        
    else
      redirect_to :analysis
      flash[:notice] = @msg
      flash[:color]= "invalid"
      return        
    end
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
        redirect_to :analysis
        flash[:notice] = "VCF file uplaoded and annotated"
        flash[:color]= "valid"        
      end
    end
  end

  def actionRank
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
      redirect_to :rank
      flash[:notice] = "You need to select a main project before proceeding with the analysis !"
      flash[:color]= "invalid"
    else  
      @msg = Corelib.rankUserAnnotatedFile(params[:fileToRank],session[:user],workspace)
      if @msg == "rank"
        redirect_to :analysis
        flash[:notice] = "Annotated file has been ranked !"
        flash[:color]= "valid"
      else
        redirect_to :rank
        flash[:notice] = "something went wrong !"
        flash[:color]= "invalid"
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
      return
    end
  end

  def workspaceFileAction
    
    @curProject = nil
    (@wspace,count) = Analysis.gWorkspace(session[:user])
    if (count == 0)
      @curProject = nil
    else
      @wspace.each do |project|
        @curProject = project  
      end
    end    
    
    @fileToShow = params[:selectedFile]
    @actionToRecognize = params[:selectedAction]

    if(params[:selectedAction] == 'Download')
      downloadFile(@fileToShow,session[:user],@curProject)
    end       
  end

  
  def downloadFile(fileToDownload,user,project)
    send_file Rails.root.join(user,project,fileToDownload), :disposition => 'attachment'
  end



end
