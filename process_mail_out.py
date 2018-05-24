import os
import subprocess
import sys

jobid =sys.argv[1]
command=sys.argv[4]
returncode=sys.argv[2]
outputfile=sys.argv[3]


def extract_mail(command):

    #so split the command, 
    ff=command.strip().split()
    #search for username/
    field_of_interest = ''
    for i in ff: 
        if i.startswith('userspace/'): 
           field_of_interest = i
           break
    if field_of_interest == '' : 
        print 'no interestin field'
        return ('','None')
    #look for username/.csv_file 
    username = field_of_interest.split('/')[1]
    if os.path.isfile('userspace/'+username+'/.csv_file.csv'):
         f = open('userspace/'+username+'/.csv_file.csv','r')
         email = f.readline().strip().split(',')[1]
         #print email
         f.close()
         return (email,username)
    else:
       print 'no csv file for username %s'%username
       return ('',username) 

def parse_command(command):
    #remove all paths basically
    ff=command.strip().split()
    outf = []
    for i in ff:
        tmp = i.split('/')[-1]
        if 'csv_file' in tmp or '.csv_file' in tmp :pass
        else : outf.append(tmp)
    return ' '.join(outf)


(email,uname) =  extract_mail(command)
if email== '':
    #there's no mail I can find so screw it
    sys.exit(0)
command = parse_command(command)
print command

with  open('mailtext.txt','w')  as wr:
  header ='''To: %s
Subject: ediva processing result
From:"Ediva Team"<rrahman@ediva.es>
'''%(email)

  if returncode == '0':
      header ='''To: %s
Subject: eDiVA  processing result
From:"Ediva Team"<rrahman@ediva.es>
'''%(email)
      wr.write(header)
      if 'annotate_template.sh' in command:
         fname = command.split(' ')[-1].split('/')[-1]
         outStr="Hello %s \n\n"%uname
         outStr+="Your Annotation job for  %s : ended successfully.\n"%fname
         outStr+="You can retreive the results in your userspace.\n"
         outStr+="Cheers \neDiVA Team \n\n-- "
      elif  'priorit' in command:
         fname = command.split(' ')[-2].split('/')[-1]
         fname  =''
         for ff in command.split(' '):
             if ff.endswith('ranked.csv'):
                fname = ff.split('/')[-1]
       
         outStr="Hello %s \n\n"%uname
         outStr+="Your Prioritization job for  %s : ended successfully.\n"%fname
         outStr+="You can retreive the results in your userspace.\n"
         outStr+="Cheers \neDiVA Team \n\n-- "
        
      wr.write(outStr)    
  else:
      header ='''To: %s
Subject: eDiVA Error report
From:"Ediva Team"<rrahman@ediva.es>
'''%(email)
      wr.write(header)
      outStr = 'Your command %s \nEnded with Error code %s \nContact us if you do not find the error cause \n\n'%(command, returncode)
      if 'annotate_template.sh' in command:
         fname = command.split(' ')[-1].split('/')[-1]
         outStr ="Hello %s \n\n"%uname
         outStr+="Your Annotation job for  %s : ended with Error %s.\n"%(fname,returncode)
         outStr+="Please contact us if you do not manage to solve the error.\n"
         outStr+="Cheers \neDiVA Team \n\n-- "
      elif  'priorit' in command:
         fname = command.split(' ')[-2].split('/')[-1]
         fname  =''
         for ff in command.split(' '):
             if ff.endswith('ranked.csv'):
                fname = ff.split('/')[-1]
         outStr ="Hello %s \n\n"%uname
         outStr+="Your Prioritization job for  %s : ended with Error %s\n"%(fname,returncode)
         outStr+="Please contact us if you do not manage to solve the error.\n"
         outStr+="Cheers \neDiVA Team \n\n-- "
      
      
      wr.write(outStr)

return_val = subprocess.call('/usr/sbin/sendmail -vt <  mailtext.txt',shell=True)
#if return_val == 0 : os.unlink('mailtext.txt')



