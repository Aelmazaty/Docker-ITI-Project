#!/bin/bash

SCRIPT_CURRENT_DIRECTORY="`dirname \"$0\"`"
FLAG=1

echo_prinT() {
local name=$1

(echo
echo -n "#"

for ((i=0;i<$((${#name}+8));i++))
do
	echo -n "-"
done

echo "#"

echo -n "#----"
if [ "$2" = "error" ]
then
	echo -ne "\e[1m\e[31m$name\e[0m"
elif [ "$2" = "head" ]
then
	echo -ne "\e[1m\e[92m$name\e[0m"
elif [ "$2" = "subhead" ]
then
	echo -ne "\e[1m\e[96m$name\e[0m"
else
	echo -ne "$name"
fi
echo  "----#"

echo -n "#"

for ((j=0;j<$((${#name}+8));j++))
do
	echo -n "-"
done

echo  "#") | tee -a $SCRIPT_CURRENT_DIRECTORY/log_error.out 


return 0

} 

header(){
	clear
	echo -e "\n**************************************************"
	echo  -e "**\t\t\t\t\t\t**"
	echo -e "**\t \e[40;38;5;82m Docker \e[30;48;5;82m Project \e[0m \t\t\t**"
	echo  -e "**\t\t\t\t\t\t**"	
	echo -e "**\t \e[40;38;5;82m Name: \e[30;48;5;82m Mohamed Ayman \e[0m \t\t**"
	echo  -e "**\t\t\t\t\t\t**"
#	echo -e "**\t \e[40;38;5;82m >>$ Press \e[30;48;5;82m Enter \e[40;38;5;82m To \e[30;48;5;82m Start \e[0m \t\t**"
#	echo  -e "**\t\t\t\t\t\t**"
	echo -e "**************************************************"
}

build() {
	####################
	# Building Images  #
	####################
	
	# Building MYSQL

	echo_prinT "+%$>>>> Building Images <<<<$%+" "head"

	echo_prinT "Installing MYSQL" "subhead"

	echo "Chaning Directory To : $SCRIPT_CURRENT_DIRECTORY/"mysql""  
	cd $SCRIPT_CURRENT_DIRECTORY/"mysql"
	echo "Bulding Image"
	sudo docker build -t mohayman/mysql .
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	cd -
	###########################################

	# Building WordPress 

	echo_prinT "Installing WordPress" "subhead"

	cd "$SCRIPT_CURRENT_DIRECTORY"/"wordpress"
	sudo docker build -t mohayman/wpdownloader .
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	cd -
	###########################################

	# Building PHP-FPM 

	echo_prinT "Installing PHP-FPM" "subhead"

	cd "$SCRIPT_CURRENT_DIRECTORY"/"php-fpm"
	sudo docker build -t mohayman/phpfpm .
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	cd - 
	###########################################

	# Building NGINX 

	echo_prinT "Installing NGINX" "subhead"

	cd "$SCRIPT_CURRENT_DIRECTORY"/"nginx"
	sudo docker build -t mohayman/nginx .
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	cd -
	##########################################
} 2>>$SCRIPT_CURRENT_DIRECTORY/log_error.out
run(){
	######################
	# Running Containers #
	######################

	echo_prinT "+%$>>>> Running containers <<<<$%+" "head"

	# Runing MYSQL Container 
	echo_prinT "Mysql Contianer" "subhead"
	sudo docker run -d --name mysql mohayman/mysql
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	##################################################

	# Runing WordPress Container
	echo_prinT "WordPress Container" "subhead"
	sudo docker run -i -t --name downloader mohayman/downloader
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	##################################################

	# Runing APPLICATION SERVER Container
	echo_prinT "Application Server Container" "subhead"
	sudo docker run -d --name app1 --volumes-from downloader --link mysql:db mohayman/phpfpm
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	##################################################

	# Runing NGINX Container
	echo_prinT "Nginx Container" "subhead"
	sudo docker run -d -p 8023:80 --name nginx --volumes-from downloader --link app1:app1 mohayman/nginx
	if [ $? -ne 0 ]
	then
		echo "[xXx] Failed : See Error Logs.
REMARK: [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out] command will execute AUTOMATICALLY."
		FLAG=0
	else
		echo "[xXx] Succeeded."
	fi

	##################################################
} 2>>$SCRIPT_CURRENT_DIRECTORY/log_error.out

echo `echo_prinT "Error LOG"` > $SCRIPT_CURRENT_DIRECTORY/log_error.out

header
sleep 1.234567890
if [ "$1" = "--build" ] || [ "$1" = "-b" ] || [ "$1" = "--run" ] || [ "$1" = "-r" ] || [ "$1" = "--build--run" ]  || [ "$1" = "-b-r" ]
then
	if [ "$1" = "--build" ] || [ "$1" = "-b" ]
	then
		build
		if [ "$FLAG" -eq 0 ]
		then
			echo  
			echo -ne "\e[1m\e[31mPress Enter To Execute [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out]\e[0m"
			read EnterKey
			echo_prinT "#######***^!^***###### Error-Log-Records #######***^!^***######" "error"
			cat $SCRIPT_CURRENT_DIRECTORY/log_error.out
		fi
	elif [ "$1" = "--run" ]  || [ "$1" = "-r" ]
	then
		run
		if [ "$FLAG" -eq 0 ]
		then
			echo
			echo -ne "\e[1m\e[31mPress Enter To Execute [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out]\e[0m"
			read EnterKey
			echo_prinT "#######***^!^***###### Error-Log-Records #######***^!^***######" "error"
			cat $SCRIPT_CURRENT_DIRECTORY/log_error.out
		fi
	elif [ "$1" = "--build--run" ]  || [ "$1" = "-b-r" ]
	then
		build	
		run
		if [ "$FLAG" -eq 0 ]
		then
			echo
			echo -ne "\e[1m\e[31mPress Enter To Execute [cat $SCRIPT_CURRENT_DIRECTORY/log_error.out]\e[0m"
			read EnterKey
			echo_prinT "#######***^!^***###### Error-Log-Records #######***^!^***######" "error"
			cat $SCRIPT_CURRENT_DIRECTORY/log_error.out
		fi
	fi
else
	echo_prinT "Error .. Please, Stick To This Instructions."
	echo "Usage: ./.../run.sh [OPTION]... "
	echo "Options:
	RMARK: Options Order Is Mandatory 
	-b, --build          	TO BUILD IMAGES.
	-r, --run           	TO RUN STACK'S CONTAINERS.
	-b-r, --build--run 	TO BUILD THE IMAGES AND THEN RUN THE CONTAINERS."	
fi 



