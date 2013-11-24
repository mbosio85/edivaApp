class Analysis
  

  def self
    con = Mysql.connect('www.ediva.crg.eu', 'edivaUser', 'edivapublic', 'eDiVaUser')
    return con
  end
  
  
  ## create new user projects
  def self.cProject(project,user,mainProject)
    
    ## check proejct in the database
    qryProject = "select * from Table_project where project = '"+ project +"' and user = '"+ user +"';"
    ccP = Analysis.new.self
    refProject = ccP.query(qryProject)
    ccP.close

    ## handle db transactions
    if refProject.num_rows != 0
      return "project"
    else
        qry = "insert into Table_project(user,project) values('"+ user +"','"+ project +"')"
        qry2 = "insert into Table_workspace(user, project) values('"+ user +"','"+ project +"')"

        cc = Analysis.new.self
        cc.query(qry)
        if (mainProject == "1")
          cc.query(qry2)               
        end
        cc.close
        
        ## create webserver physical workspace
        Dir.mkdir(Rails.root.join(user)) unless File.exists?(user)
        Dir.mkdir(Rails.root.join(user,project))

     end     

     return "success"      
  end


  ## get workspace
  def self.gWorkspace(user)
    
    workspacetoreturn = nil
    
    ## check proejct in the database
    qryProject = "select project from Table_workspace where user = '"+ user +"';"
    ccP = Analysis.new.self
    res = ccP.query(qryProject)
    ccP.close

    if res.num_rows != 0
      res.each do |r1|
        workspacetoreturn = r1
      end
    end
    return workspacetoreturn      
  end


  ## get projects
  def self.gProjects(user)
    
    projectstoreturn = nil
    
    ## check proejct in the database
    qryProject = "select project from Table_project where user = '"+ user +"';"
    ccP = Analysis.new.self
    res = ccP.query(qryProject)
    ccP.close
  
    projectstoreturn = res

    #if res.num_rows != 0
    #  res.each do |r1|
    #    projectstoreturn = r1
    #  end
    #end
    return projectstoreturn,res.num_rows      
  end

  ## change workspace
  def self.swapWorkspace(projectToChange,user)
    
    msgToReturn = nil
    
    ## update database for main project
    if (projectToChange != nil)
      ## check proejct in the database
      qryProjectUpdate = "update Table_workspace set  project = '"+ projectToChange +"' where user = '"+ user +"';"
      ccU = Analysis.new.self
      res = ccU.query(qryProjectUpdate)
      ccU.close
      msgToReturn = "change"
    end
    
    return msgToReturn
  end



end