class Fileaction
  
  def self
    
  end


  def self.showFile(file,user)
    
    data = Array.new
    
    File.open(Rails.root.join(user,project,file),'r') do |line|
      data.push(line)
    end
    
    return data,"show"    
  end

  def self.deleteFile(file,user)
    
  end

  def self.downloadFile(file,user)
    
  end



end