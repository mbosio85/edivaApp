class Fileaction
  
  def self
    
  end

<<<<<<< HEAD
  def self.showFile(file,user)
    
    data = Array.new
    
    File.open(Rails.root.join(user,file),'r') do |line|
=======
  def self.showFile(file,user,project)
    
    data = Array.new
    
    File.open(Rails.root.join(user,project,file),'r') do |line|
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f
      data.push(line)
    end
    
    return data,"show"    
  end

<<<<<<< HEAD
  def self.deleteFile(file,user)
    
  end

  def self.downloadFile(file,user)
=======
  def self.deleteFile(file,user,project)
    
  end

  def self.downloadFile(file,user,project)
>>>>>>> 125617c60d28ff78cc6dfcac741e9583c13b493f
    
  end


end