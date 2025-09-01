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

  cp /home/ec2-user/shellscript-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo

  VALIDATE $? "copying mongo repo"

  yum install -y mongodb-org

  VALIDATE $? "installing mongodb-org"

  systemctl enable mongod
  VALIDATE $? "enabling mongodb"


systemctl start mongod
  VALIDATE $? "starting mongodb"

  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
  VALIDATE $? "remote access to  mongodb"

  systemctl restart mongod
  VALIDATE $? "restarting mongod"






