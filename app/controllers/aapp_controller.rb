class AappController < ApplicationController

  before_filter :authenticate_user, :only => [:analysis]

  def analysis
    
    wspace = "userspace" + "/" + session[:user]
    
    if (!File.directory?(wspace))
      Dir.mkdir(Rails.root.join("userspace", session[:user]))
    end

    @actions = ['Preview','Download','Delete', 'Empty workspace']        
    @files = Array.new
    Dir.foreach("userspace/" + session[:user] + "/") do |file|
        next if file =~ /^\./
          @files.push(file)
    end
  end

  def annotate
    @actions = ['Preview','Download','Delete', 'Empty workspace']
    @files = Array.new
    
     Dir.foreach("userspace/" + session[:user] + "/") do |file|
       next if file =~ /^\./
        if file =~ /vcf$/ 
           @files.push(file)
        end   
     end     
  end

  def rank
    @actions = ['Preview','Download','Delete', 'Empty workspace']    
    @files = Array.new
    
     Dir.foreach("userspace/" + session[:user] + "/") do |file|
       next if file =~ /^\./
        if (file =~ /vcf$/ or file =~ /annotated$/) 
           @files.push(file)
        end
     end

  end

  def familyanalysissamples
    @actions = ['Preview','Download','Delete', 'Empty workspace']
    @files = Array.new
    Dir.foreach("userspace/" + session[:user] + "/") do |file|
        next if file =~ /^\./
          @files.push(file)
    end
  end

  def familyanalysis
    @actions = ['Preview','Download','Delete', 'Empty workspace']
    if (params[:samplecount].to_i < 2)
      redirect_to :familyanalysissamples
      flash[:notice] = "Number of samples must be 2 or more"
      flash[:color]= "invalid"
      return        
    end
    
    @analysisformtype = params[:mergedvcf]
    @numberofsamples = params[:samplecount]    

    if (@numberofsamples.to_i !=3 )
      @famTypes = ['family']      
      @inhTypes = ['dominant_denovo','dominant_inherited','recessive','Xlinked']
    else
      @famTypes = ['trio','family']
      @inhTypes = ['dominant_denovo','dominant_inherited','recessive','Xlinked','compound']      
    end

    @files = Array.new
    
    Dir.foreach("userspace/" + session[:user] + "/") do |file|
      next if file =~ /^\./
          @files.push(file)
    end      
    
  end

  def actionFamilySeparate

    printkeys = ""
    params.each { |key,value| printkeys = printkeys + "," + key}


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
      return
    else
      redirect_to :analysis
      flash[:notice] = "this portion is not active yet! use the merged vcf section please" # printkeys #@msg
      flash[:color]= "invalid"
      return        
    end
  end

  def actionFamilyMerged
    
    params.each do |key,value| 
      if (key =~ /sample/)
        if (value == "")
          redirect_to :familyanalysissamples
          flash[:notice] = "sample id cant be empty !"
          flash[:color]= "invalid"
          return
        end
      end
    end  
    
    @msg = Corelib.familyActionsMerged(params,session[:user])

    if @msg == "jobsubmitted"
      redirect_to :analysis
      flash[:notice] = "Your job has been submitted. You will receive an email when your job is completed."
      flash[:color]= "valid"
      return        
    else
      redirect_to :analysis
      flash[:notice] = @msg
      flash[:color]= "invalid"
      return        
    end
  end 


  def actionUploadFile
    
    if (params[:vcf] == nil)
      redirect_to :analysis
      flash[:notice] = "Please select a file to upload."
      flash[:color]= "invalid"
      return              
    end
    
    @msg = Corelib.uploadUserFile(params[:vcf],session[:user])
    if @msg == "uploaded"
      redirect_to :analysis
      flash[:notice] = "Your file has been uploaded."
      flash[:color]= "valid"        
      return
    else
      redirect_to :analysis
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end
  end


  def actionAnnotate
    
    if(params[:vcf] == nil and params[:fileToAnnotate] == nil)
      redirect_to :annotate
      flash[:notice] = "you need to upload a file or select a file from your workspace"
      flash[:color]= "invalid"                    
      return
    end  
    
    if (params[:fileToAnnotate] == nil)
      @msg = Corelib.handleUserFileAndAction(params[:vcf],session[:user],"annotation")      
    else
      @msg = Corelib.annotateVCF(params[:fileToAnnotate],session[:user])
    end

    if @msg == "annotated"
      redirect_to :analysis
      flash[:notice] = "Your job has been submitted. You will receive an email when your job is completed."
      flash[:color]= "valid"        
    else
      redirect_to :analysis
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"              
    end
  end

  def actionRank

    if(params[:ann] == nil and params[:fileToRank] == nil)
      redirect_to :rank
      flash[:notice] = "you need to upload a file or select a file from your workspace"
      flash[:color]= "invalid"                    
      return
    end  
    
    if (params[:fileToRank] == nil)
      @msg = Corelib.handleUserFileAndAction(params[:ann],session[:user],"rank")      
    else
      @msg = Corelib.rankUserAnnotatedFile(params[:fileToRank],session[:user])
    end
  
    if @msg == "ranked"
      redirect_to :analysis
      flash[:notice] = "Your job has been submitted. You will receive an email when your job is completed."
      flash[:color]= "valid"        
    else
      redirect_to :analysis
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"              
    end  
  
  end



  def createProject
    ## check parameter values
    if (params[:project] == "")
      redirect_to :analysis
      flash[:notice] = "Invalid project name !"
      flash[:color]= "invalid"
    elsif (params[:project] =~ /(\s)+/)
      redirect_to :analysis
      flash[:notice] = "You project name can not contain spaces !!"
      flash[:color]= "invalid"    
      return
    elsif (params[:project] =~ /[#&@!~.%+-]+/)
      redirect_to :analysis
      flash[:notice] = "You project name can not contain special character(s) !!"
      flash[:color]= "invalid"    
      return
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
    
    @actions = ['Preview','Download','Delete', 'Empty workspace']
    @files = Array.new
    Dir.foreach("userspace/" + session[:user] + "/") do |file|
      next if file =~ /^\./
          @files.push(file)
    end      


    @fileToShow = params[:selectedFile]
    @actionToRecognize = params[:selectedAction]
    @msg = nil

    if(params[:selectedAction] == 'Download')
      downloadFile(@fileToShow,session[:user])
    end
    
    if(params[:selectedAction] == 'Delete')
      rmCommand = "rm " + "userspace/" + session[:user]+ "/" + @fileToShow
      system(rmCommand)
      @msg = "delete"
    end
    
    if(params[:selectedAction] =~ /Empty/)
      rmCommand = "rm " + "userspace/" + session[:user]+ "/*.*"
      system(rmCommand)
      @msg = "alldelete"
    end

    if @msg == "delete"
      redirect_to :analysis
      flash[:notice] = @fileToShow + " file has been deleted !!"
      flash[:color]= "valid"
      return
    end
 
    if @msg == "alldelete"
      redirect_to :analysis
      flash[:notice] = "All files have been deleted !!"
      flash[:color]= "valid"
      return
    end

  end

  
  def downloadFile(fileToDownload,user)

    if(fileToDownload =~ /annotated$/ or fileToDownload =~ /ranked$/ or fileToDownload =~ /analysed$/ or fileToDownload =~ /filtered$/)
      newfileToDownload = fileToDownload + ".csv"
      scpCommand = "scp userspace/"+user+"/"+fileToDownload+ " userspace/"+user+"/"+newfileToDownload
      system(scpCommand)
      send_file Rails.root.join("userspace",user,newfileToDownload), :disposition => 'attachment'
      system("rm userspace/" + user + "/" + newfileToDownload)
    else
      send_file Rails.root.join("userspace",user,fileToDownload), :disposition => 'attachment'      
    end    

  end

  def about
    
  end
  
  def contact
    
  end

  def docs
    
  end

end
