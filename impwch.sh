#!/bin/bash
######################################################
# This script changes the password to all Users using the Bash shell
# Then offers the option to kill all active connections in case the system
# has been comprimised
# Must be ran in root
# usage: sudo ./impwch.sh
######################################################

#Get OS
SYSOS=$(cat /etc/issue | cut -d" " -f1)
echo $SYSOS

SHATTR=$(lsattr /etc/shadow | grep "\-i\-")
if [ -z "$SHATTR" ] ; then
	echo "/etc/shadow is open"
else
	echo "Removing immutability of /etc/shadow"
	chattr -i /etc/shadow
fi

#Store Input
echo "Enter New Password"
read -s PAS;
echo "Confirm New Password"
read -s PASS;

if [[ $PAS == $PASS ]] ; then 
	#Check to make sure OS is supported
	if [[ ${SYSOS} != "Ubuntu" ]] && [[ ${SYSOS} != "Fedora" ]] && [[ ${SYSOS} != "CentOS" ]] ; then
		echo "This script was not written for this OS"
		echo "If you would like to try and run anyway, enter 1 or 2 for"
		echo "Ubuntu or Fedora respectively (enter anything else to quit): "
		read SYSOS;
	fi

	#Run loops to change the password according to what system this is being ran on
	if [[ ${SYSOS} == "Ubuntu" ]] || [[ ${SYSOS} == 1 ]] ; then
		for i in $(cat /etc/passwd | grep bash | cut -d':' -f1); do
       		 	echo "Changing Password for user" $i
			echo $i":"$PAS | chpasswd;
		done
	elif [[ ${SYSOS} == "Fedora" ]] || [[ ${SYSOS} == "CentOS" ]] || [[ ${SYSOS} == 2 ]] ; then
		for i in $(cat /etc/passwd | grep bash | cut -d':' -f1); do
	       		echo "Changing Pasword for user" $i
			echo $PAS | passwd --stdin $i;
		done
	fi
	echo "don't forget to check for users using something other than bash"
	echo ""
	echo "Would you like to kill all active users? (Y/n)"
	read KILL
	if [[ $KILL == "Y" ]] ; then
		WHOME=$(tty | cut -d'/' -f3,4)
		for i in $(who -u | tr -s " " | cut -d" " -f1,2,6 | grep -v -w $WHOME | grep -v :0 | cut -d" " -f3); do
			kill $i
		done
	echo "All users killed"
	fi
else 
	echo "The Passwords you entered do not match, Nothing done"
fi

echo "Would you like to make /etc/shadow immutable? (Y/n)"
read AYE
if [[ $AYE == "Y" ]] ; then
	echo "Making /etc/shadow immutable"
	chattr +i /etc/shadow
fi
