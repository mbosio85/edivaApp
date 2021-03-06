class User
  

  def self
    con = Mysql.connect('127.0.0.1', 'edivaUser', 'edivapublic', 'eDiVaUser')
    return con
  end
  
  
  ## create new user
  def self.createSubmituser(username,email,pass)
    
    ## check email in the database
    qryEmail = "select * from Table_users where email = '"+ email +"';"
    ccU = User.new.self
    refEmail = ccU.query(qryEmail)

    ## check username in the database
    qryUser = "select * from Table_users where username = '"+ username +"';"
    ccUs = User.new.self
    refUser = ccUs.query(qryUser)


    if refEmail.num_rows != 0
      return "email"
    elsif refUser.num_rows != 0
      return "user"
    else
      ##check for username validity in the database
      qryUser = "select * from Table_users where username = '"+ username+"';"
      refUser = ccU.query(qryUser)

      if refUser.num_rows != 0
        return "user"
      else
        ## lets add salt to password and create a new pass
        pass_cleartext=pass
        (pass,salt) = encrypt_password(pass)
       
        qry = "insert into Table_users values('"+ username+"','"+ email +"','"+ pass+"','"+ salt+"')"
        
        cc = User.new.self
        cc.query(qry)
        cc.close
        ## clear password    
        pass = nil

        ## create webserver physical workspace if does not exists
        if (!(Dir.exist?(Rails.root.join("userspace", username))))
          Dir.mkdir(Rails.root.join("userspace", username)) 
        end  
        #unless File.exists?(username)
        
        ## Create  csv mailing file
        #open(Rails.root.join("userspace", username)+'/.csv_file.csv', 'w') { |f|
        #  f.puts username+','+email
        #}
         
        File.open(Rails.root.join("userspace", username, ".csv_file.csv"), 'w') do  |f|
         f.puts username+","+ email
        end 
        ## return message
       mailstr = ' echo -e "From:edivateam \nSubject:Registration \n\n  Text: Welcome ' + username + " Your eDiVA password is :" + pass_cleartext + '" |  /usr/sbin/sendmail -v ' + email
#        File.open(Rails.root.join("userspace", username, ".mail_file.csv"), 'w') do  |f|
#         f.puts mailstr
#        end
        pass_cleartext=nil


        #chmod
#        system("chmod 775 userspace/" + username  + ".mail_file.csv")
        #launch it
#        system("userspace/"+ username + "/.mail_file.csv &") 
        system(mailstr)     
    
        return "success"      
      end
      
    end
    
    ccU.close
  end
    
  ## encrypt_password
  def self.encrypt_password(password)
    salt = ""
    encrypted_password = ""
    unless password.blank?
      salt = BCrypt::Engine.generate_salt
      encrypted_password = BCrypt::Engine.hash_secret(password, salt)
    end
    return encrypted_password,salt
  end
  
  ## get email address
  def self.getemail(username)

    dbmail = ""

    qry = "select email from Table_users where username = '"+ username +"';"

    cc = User.new.self
    emailmysqlref = cc.query(qry)
    
    emailmysqlref.each do |r1|
      dbmail = r1
    end
    
    if emailmysqlref.num_rows == 0
        dbmail = "invaliduser"
    end
    
    cc.close
    return dbmail
    
  end
  
  ## validate saved user for login
  def self.validateUser(login_username,login_password)
  
    dbpass = ""
    dbsalt = ""

    qry = "select password,salt from Table_users where username = '"+ login_username +"';"

    cc = User.new.self
    usermysqlref = cc.query(qry)
    cc.close
    
    usermysqlref.each do |r1,r2|
      dbpass = r1
      dbsalt = r2
    end
    
    if (dbsalt != '')
      ## lets add salt to password to match in the database
      passnewtomatch = BCrypt::Engine.hash_secret(login_password,dbsalt)    
      if (passnewtomatch == dbpass)
        return "validuser"
      else
        return "invaliduser"
      end
    else
      return "invaliduser"
    end            
  end

  def self.reset_password(email)
    ## step 1 verify the old password is correct
    dbpass = ""
    dbsalt = ""
    uname = ""
    qry = "select password,salt from Table_users where email = '"+ email +"';"

    cc = User.new.self
    usermysqlref = cc.query(qry)
    cc.close
    
    usermysqlref.each do |r1,r2|
      dbpass = r1
      dbsalt = r2
    end
    
    
    if (dbsalt != '')
      ## lets add salt to password to match in the database
        newpass = [*('a'..'z'),*('0'..'9')].shuffle[0,10].join
        (pass,salt) = encrypt_password(newpass)
        
        qry = "UPDATE Table_users SET password='"+pass+"', salt='"+salt+"' WHERE email='"+email+"';"
        cc2 = User.new.self
        cc2.query(qry)
        cc2.close
        
            qry = "select * from Table_users where email = '"+ email +"';"

            cc3 = User.new.self
            usermysqlref2 = cc3.query(qry)
            cc3.close
            
            usermysqlref2.each do |r1,r2|
              uname = r1
              dummy = r2
            end
        
        
              
        mailCmd = "/home/rrahman/soft/ts-0.7.5/ts -N 1 python /home/rrahman/soft/python-mailer/pymailer.py -s /home/rrahman/soft/python-mailer/newpass.html userspace/"+uname+'/.csv_file.csv  ediva_new_password:'+newpass+"\n"
        system(mailCmd)
        return "validuser"
        
    else
      return "invaliduser"
    end            
  end
  
  
    def self.change_password(login_username,login_password,new_password)
    ## step 1 verify the old password is correct
        dbpass = ""
    dbsalt = ""

    qry = "select password,salt from Table_users where username = '"+ login_username +"';"

    cc = User.new.self
    usermysqlref = cc.query(qry)
    cc.close
    
    usermysqlref.each do |r1,r2|
      dbpass = r1
      dbsalt = r2
    end
    
    if (dbsalt != '')
      ## lets add salt to password to match in the database
      passnewtomatch = BCrypt::Engine.hash_secret(login_password,dbsalt)    
      if (passnewtomatch == dbpass)
        ## step 2 change the password with the new one
        ## lets add salt to password and create a new pass
        (pass,salt) = encrypt_password(new_password)
        qry = "UPDATE Table_users SET password='"+pass+"' salt='"+salt+"' WHERE username='"+login_username+"';"
        
        cc = User.new.self
        cc.query(qry)
        cc.close
        return"validuser"
      else
        return "invaliduser"
      end
    else
      return "invaliduser"
    end    
  
    
  end
    

  
end
