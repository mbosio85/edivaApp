class Corelib
  
  def self
    
  end
  
  def self.handleUserFile(userFile,user,project)
   
      valMsg = nil
      
      fl = userFile.original_filename ## file name to do rest of the things after saving
      #fl = '/Users/rrahman/Aptana Studio 3 Workspace/edivaApp/testUser/' + project.to_s + '/' + userFile.original_filename
      ## save uploaded file 
      #File.open(fl,'w') do |file|
      File.open(Rails.root.join(user,project,userFile.original_filename), 'w') do |file|
        file.write(userFile.read)
      end
      
      annotateVCF(fl,user,project)
      #annotateVCFhack(fl,user,project)
      
      valMsg = "upload" ## for validation response 
      return valMsg
  end
  
  def self.annotateVCF(userFile,user,project)
    
    annCommand = "nohup perl /home/rrahman/soft/eDiVaAnnotation/annotateSNP.pl --input /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + " --tempDir  /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + " &"
    system(annCommand) 
    
  end
  
  def self.annotateVCFhack(userFile,user,project)
    annCommand = "scp /home/rrahman/template/"+ userFile + " /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + ""
    system(annCommand)   
  end


  def self.rankUserAnnotatedFile(userFile,user,project)
      valMsg = nil
      
      ## call oliver's rank tool from ediva web server
      rankCommand = "nohup python /home/rrahman/soft/eDiVaAnnotation/rankSNP.py --infile /var/www/html/ediva/current/"+ user+ "/"+ project+ "/" + userFile + " --outfile /var/www/html/ediva/current/"+ user+ "/"+ project + "/" + userFile + ".ranked  &"
      system(rankCommand)
      
      valMsg = "rank" ## for validation response 
      return valMsg
  end
  
  
end