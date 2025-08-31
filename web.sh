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
 validate $? "installing nginix"
 

