class Corelib
  
  def self
    
  end
  
<<<<<<< HEAD
  def self.handleUserFile(userFile,user)
   
      valMsg = nil
      
      #fl = userFile.original_filename ## file name to do rest of the things after saving
      #fl = '/Users/rrahman/Aptana Studio 3 Workspace/edivaApp/testUser/' + project.to_s + '/' + userFile.original_filename
      ## save uploaded file 
      #File.open(fl,'w') do |file|
      File.open(Rails.root.join(user,userFile.original_filename), 'w') do |file|
=======
  def self.handleUserFile(userFile,user,project)
   
      valMsg = nil
      
      fl = userFile.original_filename ## file name to do rest of the things after saving
      #fl = '/Users/rrahman/Aptana Studio 3 Workspace/edivaApp/testUser/' + project.to_s + '/' + userFile.original_filename
      ## save uploaded file 
      #File.open(fl,'w') do |file|
      File.open(Rails.root.join(user,project,userFile.original_filename), 'w') do |file|
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f
        file.write(userFile.read)
      end
      
      #annotateVCF(fl,user,project)
<<<<<<< HEAD
      #annotateVCFhack(fl,user,project)
=======
      annotateVCFhack(fl,user,project)
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f
      
      valMsg = "upload" ## for validation response 
      return valMsg
  end
  
  def self.annotateVCF(userFile,user,project)
    
    annCommand = "nohup perl /home/rrahman/soft/eDiVaAnnotation/annotateSNP.pl --input /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + " --tempDir  /home/rrahman/scratch/ &"
    system(annCommand) 
    
  end
  
  def self.annotateVCFhack(userFile,user,project)
    
    if (userFile =~ /CD(.*)/)
      annCommand = "scp /home/rrahman/Template/CDs/"+ userFile + ".annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
      system(annCommand)      
    end
    if (userFile =~ /VH(.*)/)
      annCommand = "scp /home/rrahman/Template/VHs/"+ userFile + ".annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
      system(annCommand)   
    end
    
  end


<<<<<<< HEAD
  def self.rankUserAnnotatedFile(userFile,user)
      valMsg = nil
      
      ## call oliver's rank tool from ediva web server
      rankCommand = "nohup python /home/rrahman/soft/eDiVaAnnotation/rankSNP.py --infile /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + 
      " --outfile /var/www/html/ediva/current/"+ user+ "/"+ project + "/" + userFile + ".ranked  &"
=======
  def self.rankUserAnnotatedFile(userFile,user,project)
      valMsg = nil
      
      ## call oliver's rank tool from ediva web server
      rankCommand = "nohup python /home/rrahman/soft/eDiVaAnnotation/rankSNP.py --infile /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + " --outfile /var/www/html/ediva/current/"+ user+ "/"+ project + "/" + userFile + ".ranked  &"
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f
      system(rankCommand)
      
      valMsg = "rank" ## for validation response 
      return valMsg
  end
  
<<<<<<< HEAD
  def self.familyActionsMerged(sample1,sample2,sample3,affected1,affected2,affected3,vcfMerged,selectedFileMerged,inheritenceType,familyType,user,project)
=======
  def self.familyActionsMerged(sample1,sample2,sample3,affected1,affected2,affected3,vcfMerged,selectedFileMerged,inheritenceType,user,project)
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f

    valMsg = nil
    
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

    File.open(Rails.root.join(user,project,familyFile), 'w') do |file|
      file.write(sample1 + "\t" + affected1.to_s + "\n")
      file.write(sample2 + "\t" + affected2.to_s + "\n")
      file.write(sample3 + "\t" + affected3.to_s + "\n")
    end
    
    
    if (vcfMerged != nil)  
      vcfFileChecker = vcfMerged.original_filename
      valMsg = handleUserFile(vcfMerged,user,project)

      ## merge sample annotated files for ranking tool
      if (vcfFileChecker =~ /CD(.*)/)
        mergedAnnotationFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'
        annCommand = "scp /home/rrahman/Template/CDs/CD_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)      
      elsif(vcfFileChecker =~ /VH(.*)/)
        mergedAnnotationFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'                
        annCommand = "scp /home/rrahman/Template/VHs/VH_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)
      else
        ## lol you are fucked for now  
      end
      
      valMsg = rankUserAnnotatedFile(mergedAnnotationFile,user,project)      
      sleep 30
      valMsg = runFamilyAnalysisTool(rankedFile,user,project,familyFile,inheritenceType)
      valMsg = "analysis"    
      return valMsg
          
    elsif (selectedFileMerged != nil)
      ## merge sample annotated files for ranking tool
      if (selectedFileMerged =~ /CD(.*)/)
        mergedAnnotationFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'
        annCommand = "scp /home/rrahman/Template/CDs/CD_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)      
      elsif(selectedFileMerged =~ /VH(.*)/)
        mergedAnnotationFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'                
        annCommand = "scp /home/rrahman/Template/VHs/VH_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)
      else
        ## lol you are fucked for now  
      end
      ##call ranking tool from oliver 
      valMsg = rankUserAnnotatedFile(mergedAnnotationFile,user,project)      
      sleep 15
      valMsg = runFamilyAnalysisTool(rankedFile,user,project,familyFile,inheritenceType)
      valMsg = "analysis"    
    else    
      valMsg = "Your file selection is not appropriate ! Please carefully choose again !!"
    end    
    return valMsg
  end
  
<<<<<<< HEAD
  def self.familyActionsSeparate(sample1,sample2,sample3,vcf1,vcf2,vcf3,familyType,selectedFile1,selectedFile2,selectedFile3,affected1,affected2,affected3,inheritenceType,user,project)
=======
  def self.familyActionsSeparate(sample1,sample2,sample3,vcf1,vcf2,vcf3,selectedFile1,selectedFile2,selectedFile3,affected1,affected2,affected3,inheritenceType,user,project)
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f
  
    valMsg = nil
    
    if (vcf1 != nil and vcf2 != nil and vcf3 != nil)  
      ## upload VCFs
      vcfFileChecker = vcf1.original_filename
      
      valMsg = handleUserFile(vcf1,user,project)
      valMsg = handleUserFile(vcf2,user,project)
      valMsg = handleUserFile(vcf3,user,project)      
      
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

      File.open(Rails.root.join(user,project,familyFile), 'w') do |file|
        file.write(sample1 + "\t" + affected1.to_s + "\n")
        file.write(sample2 + "\t" + affected2.to_s + "\n")
        file.write(sample3 + "\t" + affected3.to_s + "\n")
      end
      
      ## merge sample annotated files for ranking tool
      if (vcfFileChecker =~ /CD(.*)/)
        mergedAnnotationFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'
        annCommand = "scp /home/rrahman/Template/CDs/CD_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)      
      elsif(vcfFileChecker =~ /VH(.*)/)
        mergedAnnotationFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'                
        annCommand = "scp /home/rrahman/Template/VHs/VH_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)
      else
        ## lol you are fucked for now  
      end

      ##call ranking tool from oliver 
      valMsg = rankUserAnnotatedFile(mergedAnnotationFile,user,project)      
      sleep 30
      valMsg = runFamilyAnalysisTool(rankedFile,user,project,familyFile,inheritenceType)
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

      File.open(Rails.root.join(user,project,familyFile), 'w') do |file|
        file.write(sample1 + "\t" + affected1.to_s + "\n")
        file.write(sample2 + "\t" + affected2.to_s + "\n")
        file.write(sample3 + "\t" + affected3.to_s + "\n")
      end
      
      ## merge sample annotated files for ranking tool
      if (selectedFile1 =~ /CD(.*)/)
        mergedAnnotationFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'CD_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'
        annCommand = "scp /home/rrahman/Template/CDs/CD_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)      
      elsif(selectedFile1 =~ /VH(.*)/)
        mergedAnnotationFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated'
        rankedFile = 'VH_.GATK.snp.filtered.cleaned.vcf.annotated.ranked'                
        annCommand = "scp /home/rrahman/Template/VHs/VH_.GATK.snp.filtered.cleaned.vcf.annotated /var/www/html/ediva/current/"+ user+ "/"+ project+ "/"
        system(annCommand)
      else
        ## lol you are fucked for now  
      end

      ##call ranking tool from oliver 
      valMsg = rankUserAnnotatedFile(mergedAnnotationFile,user,project)
      
      sleep 15
      #while(true)
        ## call family analysis tool from oliver
       # if FileTest.exists?(Rails.root + "/"+ uset+"/"+project+"/"+rankedFile)
      valMsg = runFamilyAnalysisTool(rankedFile,user,project,familyFile,inheritenceType)
        #  break
        #end
      #end
      valMsg = "analysis"    
    else    
      valMsg = "Your file selection is not appropriate ! Please carefully choose again !!"
    end
    
    return valMsg
  end
  
  def self.runFamilyAnalysisTool(rankedFile,user,project,familyFile,inhT)
    annCommand = "nohup python /home/rrahman/soft/eDiVaAnnotation/familySNP.py --infile /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + rankedFile + " --outfile /var/www/html/ediva/current/" +user+ "/"+ project+ "/" + rankedFile + "."+ inhT +".analyzed --filteredoutfile /var/www/html/ediva/current/" +user+ "/"+ project+ "/" + rankedFile + "."+ inhT +".analyzed.filtered --family /var/www/html/ediva/current/"+user+ "/"+ project+ "/family.txt --inheritance " + inhT + " &" 
    system(annCommand)          
    return annCommand
  end
  
   
end