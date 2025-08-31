#!/bim/bash
ID=$(id -u)

VALIDATE() {
if [ $1 -ne 0 ]
   then
   echo :  "installing $2 failed"
   exit 1
  else
  echo : "installing $2 success" 
 fi 
 }
if  [ $ID -ne 0 ]    
  then
     echo "run the script with root user"
   exit 1  
   else 
     echo " you are root user "
  fi   

 dnf install nginx -y  
 VALIDATE $? "installing nginix"
 
 systemctl enable nginx
 VALIDATE $? "enabling nginx"

 systemctl start nginx
 VALIDATE $? "start nginx"

 rm -rf /usr/share/nginx/html/*
 VALIDATE $? "removing files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
 VALIDATE $? "downloading files"

 cd /usr/share/nginx/html
  VALIDATE $? "downloading files"

  unzip /tmp/web.zip  
  VALIDATE $? "unzipping files"
        
 cp /home/ec2-user/shellscript-roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf 
 VALIDATE $? "copying config file"



systemctl restart nginx 

 VALIDATE $? "restarting nginix"



