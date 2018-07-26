class Corelib
  
  def self
    
  end
  
  def self.uploadUserFile(userFile,user)
   
      valMsg = nil
      ## file name to do rest of the things after saving
      fl = userFile.original_filename
      fl2 = fl.gsub!(/[^0-9A-Za-z.\-]/, '_')|| fl
      if (fl2.end_with?("vcf") || fl2.end_with?("txt")     )
          ## save uploaded file 
  #       File.open(Rails.root.join('userspace',user,userFile.original_filename), 'w') do |file|
          File.open(Rails.root.join('userspace',user,fl2), 'w') do |file|
          file.write(userFile.read)
          end
          ## set return message      
          valMsg = "uploaded"
      elsif (fl2.end_with?("gz") || fl2.end_with?("bgz") )
          File.open(Rails.root.join('userspace',user,fl2), 'wb') do |file|
          file.write(userFile.tempfile.read)
         end
         unzip = "/home/rrahman/soft/ts-0.7.5/ts -N 1 gzip -d userspace/" + user + '/' + fl 
         system(unzip)
        valMsg = "uploaded gz" 
      elsif (fl2.end_with?("zip") )
          File.open(Rails.root.join('userspace',user,fl2), 'wb') do |file|
          file.write(userFile.tempfile.read)
         end
         unzip = "/home/rrahman/soft/ts-0.7.5/ts -N 1 unzip -o  -d  userspace/" + user + "/  userspace/" + user + '/' + fl 
         system(unzip)
        valMsg = "uploaded gz" 
      else
          valMsg = 'Error not a VCF or TXT, nor Gzipped or Zipped file'
      end
      return valMsg
      
  end

  
  def self.handleUserFileAndAction(userFile,user,action)
   
      valMsg = nil
   
      ## save uploaded file
      valMsg = uploadUserFile(userFile,user)
      
      if(valMsg == "uploaded")        
      
        if(action == "annotation" )
          ## annotate the uploaded vcf      
          valMsg = annotateVCF(userFile.original_filename,user)
        else
          ## rank the uploaded file      
          valMsg = rankUserAnnotatedFile(userFile.original_filename,user)
        end
      end 
        
      return valMsg
      
  end  


  def self.annotateVCF(userFile,user)
    
      valMsg = nil
      jobscript = ".jobtosubmit.sh"
      csv_file = ".csv_file.csv"
      
      usermail = User.getemail(user)
      mail = usermail.to_s[2..-3]

      ## write csv file
      File.open(Rails.root.join("userspace",user,csv_file), 'w') do |file|
        file.write(user + "," + mail + "\n")
      end
      
      ## delete the target file(s) if exists
      delcmmd = "rm userspace/" + user + "/" + jobscript
      system(delcmmd)
      
      ## call ediva-tools annotation program to calculate rank of the variants
      annCommand = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n"
      ##annCommand = annCommand + "ts -N 1 python edivatools-code/Annotate/annotate.py --input userspace/" + user + "/"+ userFile + 
      ##" -s complete -f --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1"

      tmpdir  = (0...50).map { ('a'..'z').to_a[rand(32)] }.join
      annCommand = annCommand +  "mkdir -p /tmp/" + tmpdir + " \n"
      annCommand = annCommand + "/home/rrahman/soft/ts-0.7.5/ts -N 1 sh templates/annotate_template.sh  " + tmpdir + " "  + user + "  userspace/" + user + "/" + userFile 

      ## write line to job file
      File.open(Rails.root.join("userspace",user,jobscript), 'w') do |file|
        file.write(annCommand + "\n")
      end
      

      ## chmod
      system("chmod 775 userspace/" + user + "/" + jobscript)
      ## start the job
      system("userspace/"+ user + "/" + jobscript + " &")

      ## set return message
      valMsg = "annotated"
      
      return valMsg

  end
 
  def self.rankUserAnnotatedFile(userFile,user)

      valMsg = nil
      jobscript = ".jobtosubmit.sh"
      csv_file = ".csv_file.csv"

      usermail = User.getemail(user)
      mail = usermail.to_s[2..-3]

      ## write csv file
      File.open(Rails.root.join("userspace",user,csv_file), 'w') do |file|
        file.write(user + "," + mail + "\n")
      end

      ## delete the target file(s) if exists
      delcmmd = "rm userspace/" + user + "/" + jobscript
      system(delcmmd)

      ## if vcf file was provided then annotate it first
      if (userFile =~ /vcf$/)
        ## call ediva-tools annotation program to calculate rank of the variants
        annCommand = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n "
        annCommand = annCommand +  " ts -N 1 python edivatools-code/Annotate/annotate.py --input userspace/" + user + "/"+ userFile + 
        " -s complete -f --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1"
       

       ###
       ### <--- ADD here template execution for annotation. Remember that the rank part is no longer written to the jobtosubmit
       ###
       annCommand = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n"
       tmpdir  = (0...50).map { ('a'..'z').to_a[rand(32)] }.join
       annCommand = annCommand +  "mkdir -p /tmp/" + tmpdir + " \n"
       annCommand = annCommand + "/home/rrahman/soft/ts-0.7.5/ts -N 1 sh templates/annotate_template.sh  " + tmpdir + " "  + user + "  userspace/" + user + "/" + userFile
       ###
       ### <<<<<<<<<<<<<
       ###                              
        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
          file.write(annCommand + "\n")
        end
        
        ## update filename    
        userFile = userFile.chomp('.vcf') + '.sorted.annotated.csv'
        ## call ediva-tools rank program to calculate rank of the variants
        rankCommand = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n"
        rankCommand = rankCommand+ "ts -N 1 Rscript edivatools-code/Prioritize/wrapper_call.R edivatools-code/Prioritize/ediva_score.rds " +
        "userspace/" + user + "/"+ userFile +" userspace/"+ user + "/" + userFile.chomp('.csv') +
         ".ranked.csv    > userspace/"+ user + "/.job.log 2>&1"
        
        ## write line to job file
        #File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
        #  file.write(rankCommand + "\n")
        #end        
        
      else
        ## call ediva-tools rank program to calculate rank of the variants
        rankCommand = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n "
        rankCommand = rankCommand+ "ts -N 1 Rscript edivatools-code/Prioritize/wrapper_call.R edivatools-code/Prioritize/ediva_score.rds " +
        "userspace/" + user + "/"+ userFile +" userspace/"+ user + "/" + userFile.chomp('.csv') +
         ".ranked.csv    > userspace/"+ user + "/.job.log 2>&1"
         #rankCommand + "ts -N 1 python edivatools-code/Prioritize/rankSNP.py --infile userspace/" + user + "/"+ userFile + 
         #" --outfile userspace/"+ user + "/" + userFile.chomp('.csv') +
         # ".ranked.csv   --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1"
        
        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
          file.write(rankCommand + "\n")
        end        
      end

      
      ## chmod
      system("chmod 775 userspace/" + user + "/" + jobscript)
      ## start the job
      system("userspace/"+ user + "/" + jobscript + " &")
      ## set return message
      valMsg = "ranked"

      return valMsg

  end    
  

  def self.familyActionsMerged(params,user,hpoTermFileName)

    valMsg = nil
    
    ## check params[:commit]
    if params[:commit]=="eDiVA v1 Analysis"
      familySNP = 'familySNP.py'
    else
      familySNP = 'familySNP.py'
    end
    
    mergedAnnotationFile = nil
    familyFile = 'family.txt'
    jobscript = ".jobtosubmit.sh"
    csv_file = ".csv_file.csv"
    
    usermail = User.getemail(user)
    mail = usermail.to_s[2..-3]

    ## write csv file
    File.open(Rails.root.join("userspace",user,csv_file), 'w') do |file|
       file.write(user + "," + mail + "\n")
    end
    
    ## delete the target file(s) if exists
    delcmmd = "rm userspace/" + user + "/" + familyFile
    system(delcmmd)
    delcmmd = "rm userspace/" + user + "/" + jobscript
    system(delcmmd)
    
    commands = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n"
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
     end
    
    

    #else
      mergedAnnotationFile = params[:selectedFileMerged]

       commands = "" 
       ## write the family script
       params.each do |key,value| 
         if (key =~ /sample/)
           sampleindex = key[6..key.length]
           affectstatus = 1
           if (params[:"affected#{sampleindex}"] == nil)
             affectstatus = 0
           end
           File.open(Rails.root.join("userspace",user,familyFile), 'a') do |file|
             file.write(value + "\t" + affectstatus.to_s + "\n")
           end
         end
       end  

       if(mergedAnnotationFile =~ /ranked$/ or mergedAnnotationFile =~/ranked.csv$/)
#        =begin   
#        ## family script
#          commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Prioritize/"+familySNP+" --infile userspace/" + user + "/" +
#           mergedAnnotationFile + " --outfile userspace/" +
#          user + "/" + mergedAnnotationFile.chomp('sorted.annotated.ranked.csv') +params[:inheritenceType]+ ".csv --filteredoutfile userspace/" + user +
#           "/" + mergedAnnotationFile.chomp('sorted.annotated.ranked.csv')  + "filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
#          user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] 
#          if (params[:geneexclusionlist] == "1")
#          commands = commands + " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt " 
#          end
#          if (params[:whitelist] == "1") 
#          if (params[:vcf] != nil)
#               commands = commands + " --white_list userspace/" + user + "/" +params[:vcf] + "  "
#            end
#         end          
#          commands = commands +  " --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n" 
#         =end 
##          if (params[:inheritenceType] == "all")
             tmpdir  = (0...50).map { ('a'..'z').to_a[rand(32)] }.join 
             commands = "mkdir -p /tmp/" + tmpdir + " \n"

             if (params[:vcf] != nil)
                 commands = commands +  "cp userspace/" + user + "/" + params[:vcf] + " /tmp/" + tmpdir + "/.hpo.txt \n"
             else
                 commands = commands + "touch /tmp/" + tmpdir + "/.hpo.txt \n "  
             end

             commands = commands + "/home/rrahman/soft/ts-0.7.5/ts -N 1 sh templates/prioritize_template.sh " + " " + tmpdir + " " + user + " " + params[:inheritenceType]   + " " + params[:familyType] +
                        "  userspace/" + user + "/" +  mergedAnnotationFile 
             if (params[:geneexclusionlist] == "1")
                 commands = commands + "  edivatools-code/Resource/gene_exclusion_list.txt "
             end

##          end

        
        
        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
         file.write(commands + "\n")
        end
       
       else

        valMsg = "Unknown file type provided in the analysis ! It must be .ranked.csv"
        return valMsg

       end        
       
       ## chmod
       system("chmod 775 userspace/" + user + "/" + jobscript)
       ## start the job
       system("userspace/"+ user + "/" + jobscript + " &")
       ## set return message       
       valMsg = "jobsubmitted"
    
    return valMsg

  end
  

  def self.familyActionsSeparate(sample1,sample2,sample3,vcf1,vcf2,vcf3,familyType,selectedFile1,selectedFile2,selectedFile3,affected1,affected2,affected3,inheritenceType,user,project)
  
      valMsg = "analysis"

    if (vcf1 != nil and vcf2 != nil and vcf3 != nil)  
      ## upload VCFs
      vcfFileChecker = vcf1.original_filename
      
      valMsg = uploadUserFile(vcf1,user)
      valMsg = uploadUserFile(vcf2,user)
      valMsg = uploadUserFile(vcf3,user)      
      
      mergedAnnotationFile = nil
      rankedFile = nil
      ## write the initial family file for the family script from oliver      
      familyFile = 'family.txt'
      ## handle affected nil parameters
      if (affected1 == nil)
        affected1 = 0
      end
      if (affected2 == nil)
        affected2 = 0
      end
      if (affected3 == nil)
        affected3 = 0
      end

      File.open(Rails.root.join(user,familyFile), 'w') do |file|
        file.write(sample1 + "\t" + affected1.to_s + "\n")
        file.write(sample2 + "\t" + affected2.to_s + "\n")
        file.write(sample3 + "\t" + affected3.to_s + "\n")
      end
      
      ## merge sample annotated files for ranking tool
      if (vcfFileChecker =~ /CD(.*)/)
        mergedAnnotationFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'
        annCommand = "/home/rrahman/soft/ts-0.7.5/ts -N 1 scp /home/rrahman/Template/CDs/CD_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/" 
        system(annCommand)      
      elsif(vcfFileChecker =~ /VH(.*)/)
        mergedAnnotationFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'                
        annCommand = "/home/rrahman/soft/ts-0.7.5/ts -N 1 scp /home/rrahman/Template/VHs/VH_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"
        system(annCommand)
      else
        ## lol you are fucked for now  
      end

      ##call ranking tool from oliver 
      valMsg = rankUserAnnotatedFile(mergedAnnotationFile,user)      
      sleep 30
      valMsg = runFamilyAnalysisTool(rankedFile,user,familyFile,inheritenceType)
      valMsg = "analysis"    
      return valMsg
  
    elsif(selectedFile1 != nil and selectedFile2 != nil and selectedFile3 != nil)
      
      mergedAnnotationFile = nil
      rankedFile = nil
      ## write the initial family file for the family script from oliver      
      familyFile = 'family.txt'
      ## handle affected nil parameters
      if (affected1 == nil)
        affected1 = 0
      end
      if (affected2 == nil)
        affected2 = 0
      end
      if (affected3 == nil)
        affected3 = 0
      end

      File.open(Rails.root.join(user,familyFile), 'w') do |file|
        file.write(sample1 + "\t" + affected1.to_s + "\n")
        file.write(sample2 + "\t" + affected2.to_s + "\n")
        file.write(sample3 + "\t" + affected3.to_s + "\n")
      end
      #
      # merge sample annotated files for ranking tool
      if (selectedFile1 =~ /CD(.*)/)
        mergedAnnotationFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'
        annCommand = "/home/rrahman/soft/ts-0.7.5/ts -N 1 scp /home/rrahman/Template/CDs/CD_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+  "/"
        system(annCommand)      
      elsif(selectedFile1 =~ /VH(.*)/)
        mergedAnnotationFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'                
        annCommand = "/home/rrahman/soft/ts-0.7.5/ts -N 1 scp /home/rrahman/Template/VHs/VH_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"
        system(annCommand)
      else
        ## lol you are fucked for now  
      end

      ##call ranking tool from oliver 
      valMsg = rankUserAnnotatedFile(mergedAnnotationFile,user)
      
      sleep 15
      #while(true)
        ## call family analysis tool from oliver
       # if FileTest.exists?(Rails.root + "/"+ uset+ "/"+project+ "/"+rankedFile)
      valMsg = runFamilyAnalysisTool(rankedFile,user,familyFile,inheritenceType)
        #  break
        #end
      #end
      valMsg = "analysis"    
    else    
      valMsg = "Your file selection is not appropriate ! Please carefully choose again !!"
    end

    return valMsg
  end


  def self.familyActionsSeparate_2(params,user)
    #Algorthm idea
    # paramteres will be params and user
    # first test with local files
    
    # 
    # or with vcftools-merge but it needs vcf processed by bgzip and tabix to run
    # launch VCF merging
    # then call the Merged function with params,user and it should be done ! problem is to merge VCF
    # then for each sample, delete the vcf.gz files as well and return the correct word
    sn= "/var/www/html/ediva/current/userspace/"+ user+ "/"
    bgzip ="/home/rrahman/soft/tabix-0.2.6/bgzip -f "
    tabix ="/home/rrahman/soft/tabix-0.2.6/tabix -f "
    command = "PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ \n export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail \n"
    command = command+ "/home/rrahman/soft/ts-0.7.5/ts -N 1 "+bgzip+ " "+sn+ params[:selectedFile1]+ " ; /home/rrahman/soft/ts-0.7.5/ts -N 1 "+tabix + " -p vcf -f "+sn+params[:selectedFile1]+ ".gz\n"
    command = command+ "/home/rrahman/soft/ts-0.7.5/ts -N 1 "+bgzip+ " "+sn+params[:selectedFile2]+ " ; /home/rrahman/soft/ts-0.7.5/ts -N 1 "+tabix + " -p vcf -f "+sn+params[:selectedFile2]+ ".gz\n"
    command = command+ "/home/rrahman/soft/ts-0.7.5/ts -N 1 "+bgzip+ " "+sn+params[:selectedFile3]+ " ; /home/rrahman/soft/ts-0.7.5/ts -N 1 "+tabix + " -p vcf -f "+sn+params[:selectedFile3]+ ".gz\n"
    command = command+ " /home/rrahman/soft/ts-0.7.5/ts -N 1 perl /home/rrahman/vcftools_0.1.12b/perl/vcf-merge "+sn+params[:selectedFile1]+ ".gz "+sn+params[:selectedFile2]+ ".gz " +sn+params[:selectedFile3]+ ".gz > .test\n"
    command = command+ "export TS_ONFINISH='/home/rrahman/soft/ts-0.7.5/copy_output.sh'\n"#;  chmod 777 $TS_ONFINISH \n"
    command = command+ "ts cp .temp_result "+sn+ "merged.vcf \n"
    system(command)
    #To do list
    # Install bgzip tabix and vcftools on the machine /home/rrahman/soft -check
    # Test the process once without web - check
    # Test the process with the web -check
    
    oo=command
    return oo
  end

  
  def self.runFamilyAnalysisTool(rankedFile,user,familyFile,inhT)
    annCommand = "/home/rrahman/soft/ts-0.7.5/ts -N 1 nohup python /home/rrahman/soft/eDiVaAnnotation/familySNP.py --infile /var/www/html/ediva/current/"+ user+ "/"+  rankedFile + " --outfile /var/www/html/ediva/current/" +user+ "/"+  rankedFile + "."+ inhT + ".analyzed --filteredoutfile /var/www/html/ediva/current/" +user+ "/"+  + rankedFile + "."+ inhT + ".analyzed.filtered --family /var/www/html/ediva/current/"+user+ "/"+ "/family.txt --inheritance " + inhT + " &" 
    system(annCommand)          
    return annCommand
    
  end
  
  def self.extract_sample_names(userFile,user)
    File.open('yourfile.txt', 'w') { |file| file.write(userFile) }
    ary = Array.new ;
    File.open(['userspace',user,userFile].join('/'), "r") do |file_handle|
      file_handle.each_line do |line|
      # do stuff here : read line and all places before DP are samples
      fields = line.split(',');
#      dp_idx = fields.each_index.select{|i| fields[i] =~ /^DP/};    
      dp_idx = fields.each_index.select{|i| fields[i] =~ /^#/};
#      dp_idx.each { |x| ary.push( fields[x-1]) };
    
      start  = dp_idx.last.to_i + 1;
      endval = fields.length-2;
      ary  =  (start..endval).step(6).map{|x| fields[x]};
#      dp_idx.each { |x| ary.push( fields[x]) };



      # now here I have an array with  sample names
  
      break
      end
    end
   
    return ary
  end
  

def self.deleted_lines_from_family_processig_for_backup_future_if_needed()
  ## upload user file or select the file from userspace
    if (params[:vcfMerged])
      
      valMsg = uploadUserFile(params[:vcfMerged],user)

      if (valMsg == "uploaded")
        filename = params[:vcfMerged].original_filename
        commands = "" 
        ## write the family script
        params.each do |key,value| 
          if (key =~ /sample/)
            sampleindex = key[6..key.length]
            affectstatus = 1
            if (params[:"affected#{sampleindex}"] == nil)
              affectstatus = 0
            end
            File.open(Rails.root.join("userspace",user,familyFile), 'a') do |file|
              file.write(value + "\t" + affectstatus.to_s + "\n")
            end
          end
        end  
        
        
        
        if (filename =~ /vcf$/)
          ## call ediva-tools annotation program to calculate rank of the variants
          
          commands = "ts -N 1 python edivatools-code/Annotate/annotate.py --input userspace/" + user + "/"+ filename + 
          " -s complete -f --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
          ## write line to job file
          File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
        end
        
          ## update filename as per annotation tool
          ## remove the .vcf extension from file name
          ##filename = filename[0..-5]
          filename = filename.chomp('.vcf') + '.sorted.annotated.csv'
          ## rank line
          commands ="ts -N 1 Rscript edivatools-code/Prioritize/wrapper_call.R edivatools-code/Prioritize/ediva_score.rds " +
          "userspace/" + user + "/"+ filename + " userspace/"+ user + "/" + filename.chomp('.csv') +
          ".ranked.csv    > userspace/"+ user + "/.job.log 2>&1 \n"
          
          # "ts -N 1 python edivatools-code/Prioritize/rankSNP.py --infile userspace/" + user + "/"+ filename  +  
          #" --outfile userspace/"+ user + "/" + filename.chomp('.csv') + ".ranked.csv  --csvfile /var/www/html/ediva/current/userspace/"+
          # user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
          ## write line to job file
          File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
          end
      
          ## family script
          if (params[:geneexclusionlist] == "1")
            #commands = "python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename + ".sorted.annotated.ranked --outfile userspace/" +
            #user + "/" + filename + ".sorted.annotated.ranked.analysed --filteredoutfile userspace/" + user + "/" + filename + ".sorted.annotated.ranked.analysed.filtered --family userspace/"+
            #user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt "+
            #"--csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + "  > userspace/"+ user + "/.job.log 2>&1"
            commands = "ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename.chomp('.csv') + ".ranked.csv --outfile userspace/" +
            user + "/" + filename.chomp('.csv') + ".ranked.analysed."+ params[:inheritenceType] + ".csv --filteredoutfile userspace/" + user + "/" +
            filename.chomp('.csv') + ".ranked.analysed.filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
            user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt "+
            "--csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + "  > userspace/"+ user + "/.job.log 2>&1\n"
          else
            #commands = "python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename + ".sorted.annotated.ranked --outfile userspace/" +
            #user + "/" + filename + ".sorted.annotated.ranked.analysed --filteredoutfile userspace/" + user + "/" + filename + ".sorted.annotated.ranked.analysed.filtered --family userspace/"+
            #user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1"   
            commands = "ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename.chomp('.csv') + ".ranked.csv --outfile userspace/" +
             user + "/" + filename.chomp('.csv') + ".ranked.analysed." + 
             params[:inheritenceType] + ".csv --filteredoutfile userspace/" + user + "/" + filename.chomp('.csv') +
             ".ranked.analysed.filtered." + params[:inheritenceType] + ".csv --family userspace/"+ user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1"
   
           end
          ## write line to job file
          File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
         end
        
        elsif( filename =~ /annotated.csv$/ or filename =~ /annotated$/ )

          ## rank line
          commands = "ts -N 1 Rscript edivatools-code/Prioritize/wrapper_call.R edivatools-code/Prioritize/ediva_score.rds " +
         "userspace/" + user + "/"+ filename + " userspace/"+ user + "/" + filename.chomp('.csv') +
         ".ranked.csv    > userspace/"+ user + "/.job.log 2>&1\n"
          
          #python edivatools-code/Prioritize/rankSNP.py --infile userspace/" + user + "/"+ filename +   
          #" --outfile userspace/"+ user + "/" + filename.chomp('.csv') + ".ranked.csv  --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1\n"
          ## write line to job file
          File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
          end

          ## family script
          if (params[:geneexclusionlist] == "1")
            commands = "ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename.chomp('.csv') + ".ranked.csv --outfile userspace/" +
            user + "/" + filename.chomp('.csv') + ".ranked.analysed."+ params[:inheritenceType] + ".csv --filteredoutfile userspace/" + user + "/" + filename.chomp('.csv') + 
            ".ranked.analysed.filtered."+ params[:inheritenceType] + ".csv --family userspace/"+
            user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt "+
            "--csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + "  > userspace/"+ user + "/.job.log 2>&1 \n"
          else
            commands = "ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename.chomp('.csv') +
            ".ranked.csv --outfile userspace/" + user + "/" + filename.chomp('.csv') + ".ranked.analysed."+ params[:inheritenceType] +
            ".csv --filteredoutfile userspace/" + user + "/" + filename.chomp('.csv') + ".ranked.analysed.filtered."+ params[:inheritenceType] + ".csv --family userspace/"+
            user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --csvfile /var/www/html/ediva/current/userspace/"+ 
            user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"   
          end
          ## write line to job file
          File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
          end
          
        elsif( filename =~ /ranked$/ or filename =~ /ranked.csv$/)
          
          ## family script
          if (params[:geneexclusionlist] == "1")
            commands = "ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename + " --outfile userspace/" +
            user + "/" + filename.chomp('.csv') + ".analysed."+ params[:inheritenceType] +
            ".csv --filteredoutfile userspace/" + user + "/" + filename.chomp('.csv') + ".analysed.filtered."+ params[:inheritenceType] + ".csv --family userspace/"+
            user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt "+
            "--csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + "  > userspace/"+ user + "/.job.log 2>&1 \n"
          else
            commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" + filename+
            " --outfile userspace/" + user + "/" + filename.chomp('.csv') + ".analysed."+params[:inheritenceType]+
            ".csv --filteredoutfile userspace/" + user + "/" + filename.chomp('.csv') + ".analysed.filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
            user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] +
             " --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"   
          end
          ## write line to job file
          File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
            file.write(commands + "\n")
          end
          
        else
  
          valMsg = "Unknown file type provided in the analysis !"+filename
          return valMsg

        end
          
        ## chmod
        system("chmod 775 userspace/" + user + "/" + jobscript)
        ## start the job
        system("userspace/"+ user + "/" + jobscript + " &")
        ## set return message       
        valMsg = "jobsubmitted"
      end  
    
    
  else
    if (mergedAnnotationFile =~ /vcf$/)

        ## call ediva-tools annotation program to calculate rank of the variants
        commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Annotate/annotate.py --input userspace/" + user + "/"+ mergedAnnotationFile + 
        " -s complete -f --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
          file.write(commands + "\n")
        end
        
        ## update filename as per annotation tool
        ## remove the .vcf extension from file name
        ## mergedAnnotationFile = mergedAnnotationFile[0..-5]
        ##mergedAnnotationFile = mergedAnnotationFile + ".sorted.annotated"
        mergedAnnotationFile = mergedAnnotationFile.chomp('.vcf')+'.sorted.annotated.csv'
        ## rank line
        commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python  Rscript edivatools-code/Prioritize/wrapper_call.R edivatools-code/Prioritize/ediva_score.rds " +
        "userspace/" + user + "/"+ mergedAnnotationFile + " userspace/"+ user + "/" + mergedAnnotationFile.chomp('.csv') +
         ".ranked.csv    > userspace/"+ user + "/.job.log 2>&1 \n"
        
        #edivatools-code/Prioritize/rankSNP.py --infile userspace/" + user + "/"+ mergedAnnotationFile +   
        #" --outfile userspace/"+ user + "/" + mergedAnnotationFile.chomp('.csv') + ".ranked.csv  --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
          file.write(commands + "\n")
        end         
               
    
        ## family script
        if (params[:geneexclusionlist] == "1")
          commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" +
           mergedAnnotationFile.chomp('.csv') + ".ranked.csv --outfile userspace/" +
          user + "/" + mergedAnnotationFile.chomp('.csv') + ".ranked.analysed."+params[:inheritenceType]+
          ".csv --filteredoutfile userspace/" + user + "/" + mergedAnnotationFile.chomp('.csv') + ".ranked.analysed.filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
          user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] + " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt "+
          "--csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
        else
          commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" +
          mergedAnnotationFile.chomp('.csv') + ".ranked.csv --outfile userspace/" +
          user + "/" + mergedAnnotationFile.chomp('.csv') + ".ranked.analysed."+params[:inheritenceType]+
          ".csv --filteredoutfile userspace/" + user + "/" + mergedAnnotationFile.chomp('.csv') + ".ranked.analysed.filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
          user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType]  + " --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + 
          csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"  
        end

        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
         file.write(commands + "\n")
        end

       elsif (mergedAnnotationFile =~ /annotated$/ or mergedAnnotationFile =~ /annotated.csv$/)

        ## rank line
        commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1  Rscript edivatools-code/Prioritize/wrapper_call.R edivatools-code/Prioritize/ediva_score.rds " +
        "userspace/" + user + "/"+ mergedAnnotationFile + " userspace/"+ user + "/" +  mergedAnnotationFile.chomp('.csv')  +
         ".ranked.csv    > userspace/"+ user + "/.job.log 2>&1"
        
        #python edivatools-code/Prioritize/rankSNP.py --infile userspace/" + user + "/"+ mergedAnnotationFile +   
        #" --outfile userspace/"+ user + "/" + mergedAnnotationFile.chomp('.csv') + ".ranked.csv  --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
          file.write(commands + "\n")
        end         

        ## family script
        if (params[:geneexclusionlist] == "1")
          commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" +
           mergedAnnotationFile.chomp('.csv')  + ".ranked.csv --outfile userspace/" +
          user + "/" + mergedAnnotationFile.chomp('.csv')  + ".ranked.analysed."+params[:inheritenceType]+ ".csv --filteredoutfile userspace/" + user + "/" +
           mergedAnnotationFile.chomp('.csv')  + ".ranked.analysed.filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
          user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType] +
           " --geneexclusion edivatools-code/Resource/gene_exclusion_list.txt "+
          "--csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"
        else
          commands = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python edivatools-code/Prioritize/familySNP.py --infile userspace/" + user + "/" +
           mergedAnnotationFile.chomp('.csv')  + ".ranked.csv --outfile userspace/" +
          user + "/" + mergedAnnotationFile.chomp('.csv')  + ".ranked.analysed."+params[:inheritenceType]+ ".csv --filteredoutfile userspace/" +
           user + "/" + mergedAnnotationFile.chomp('.csv')  + ".ranked.analysed.filtered."+params[:inheritenceType]+ ".csv --family userspace/"+
          user + "/" + familyFile + " --inheritance " + params[:inheritenceType] + " --familytype " + params[:familyType]  +
           " --csvfile /var/www/html/ediva/current/userspace/"+ user + "/" + 
          csv_file + " > userspace/"+ user + "/.job.log 2>&1 \n"  
        end

        ## write line to job file
        File.open(Rails.root.join("userspace",user,jobscript), 'a') do |file|
         file.write(commands + "\n")
        end
     end
  return nil
  end
  
  end
   
end
