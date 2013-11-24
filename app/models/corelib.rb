class Corelib
  
  def self
    
  end
  
  def self.handleUserFile(userFile,user,project)
   
      data = Array.new
      valMsg = nil
      
      fl = userFile.original_filename ## file name to do rest of the things after saving
      #fl = '/Users/rrahman/Aptana Studio 3 Workspace/edivaApp/testUser/' + project.to_s + '/' + userFile.original_filename
      ## save uploaded file 
      #File.open(fl,'w') do |file|
      File.open(Rails.root.join(user,project,userFile.original_filename), 'w') do |file|
        file.write(userFile.read)
      end
      
      annotateVCF(fl,user,project)
      
        
      valMsg = "upload" ## for validation response 
      return valMsg
  end
  
  def self.annotateVCF(userFile,user,project)
    
    #annCommand = "perl /Users/rrahman/ExomeCourseTest/eDiVaAnnotation/annotateSNP.pl --input /Users/rrahman/ExomeCourseTest/sample.test.vcf --tempDir /Users/rrahman/ExomeCourseTest"
    annCommand = "perl /home/rrahman/soft/eDiVaAnnotation/annotateSNP.pl --input /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + " --tmpDir  /home/rrahman/scratch"
    #annCommand = "perl /home/rrahman/soft/eDiVaAnnotation/annotateSNP.pl --input "+ Rails.root.join(user,project,userFile).to_s + " --tmpDir " + Rails.root.join(user,project).to_s + "" 
    system(annCommand) 
    
  end
  
  
  
  
end