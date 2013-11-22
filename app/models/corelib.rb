class Corelib
  
  def self
    
  end
  
  def self.handleUserFile(userFile,user,project)
   
      data = Array.new
      valMsg = nil
      
      #fl = userFile.original_filename ## file name to do rest of the things after saving
      
      ## save uploaded file 
      File.open(Rails.root.join(user,project,userFile.original_filename), 'w') do |file|
        file.write(userFile.read)
      end
      
      valMsg = "upload" ## for validation response 
      return valMsg
  end
  
  def self.annotateVCF(userFile,user,project)
    
  end
  
  
  
  
end