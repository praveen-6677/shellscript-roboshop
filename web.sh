#!/bim/bash
ID=$(id -u)

VALIDATE() {
if [ $1 -ne 0 ]
   then
   echo :  "installing $2 failed"
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

 unzip /tmp/web.zip
 VALIDATE $? "unziping files"

 cp /home/ec-2user/roboshop.conf /etc/nginx/default.d
 VALIDATE $? "copying config file"



systemctl restart nginx 

 VALIDATE $? "restarting nginix"



