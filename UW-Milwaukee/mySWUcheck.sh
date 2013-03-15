#!/bin/bash
##############
# This script will run Software updates and will check if the updates need to reboot or not. 
#
# This script is meant to be used at log out. It will allow the user to not do the software updates 3 times. 
# The 4th time the user does not get a choice about installing the updates. They will just install and display a warning message. 
#
# This was writen by
# Kyle Brockman
# While working for Univeristy Information Technology Servives
# at the Univeristy of Wisconsin Milwaukee
##############


YES=`echo "button returned:Yes"`
NO=`echo "button returned:No"`

if [ -f /var/db/.uitsSoftwareUpdate ]; then
	echo "file is here"
else
	echo "0" > /var/db/.uitsSoftwareUpdate
	echo "made the file"
fi

FILECOUNT=`cat /var/db/.uitsSoftwareUpdate`

/usr/sbin/softwareupdate -l | grep "restart"

if [[ `/bin/echo "$?"` == 1 ]] ; then #updates with no reboot
	if [ $FILECOUNT == "3" ]; then
			echo "forcing update after 3 NOs"
			/usr/bin/osascript <<-EOF
				    tell application "System Events"
				        activate
				        display dialog "Software updates are being applied. Please do not shutdown, close the lid, or reboot your computer now. This could damage it and require a rebuild with DATA LOSS!!" buttons {"OK"}
				    end tell
			EOF
			/usr/sbin/softwareupdate -i -a
			sleep 30
			echo "0" > /var/db/.uitsSoftwareUpdate
			cat /var/db/.uitsSoftwareUpdate
			
		else
		FIRST=`/usr/bin/osascript <<-EOF
		    tell application "System Events"
		        activate
		        display dialog "There are currently software updates that need to be installed. Would you like to install them now?" buttons {"No","Yes"} default button 2
		    end tell
		EOF`
	
		if [ "$FIRST" == "$YES" ]; then
	
			echo "Uesr clicked yes first time"
			echo "Installing all updates"
			/usr/sbin/softwareupdate -i -a
			echo "0" > /var/db/.uitsSoftwareUpdate
			cat /var/db/.uitsSoftwareUpdate
	
		else
	
			echo "User clicked no first time"
			NUM=$(($FILECOUNT + 1))
			echo $NUM > /var/db/.uitsSoftwareUpdate
			echo $NUM
			exit 1
	
		fi
	fi 
#####	
else #updates with reboot
#####	
	if [ $FILECOUNT == "3" ]; then
			echo "forcing update after 3 NOs"
			/usr/bin/osascript <<-EOF
				    tell application "System Events"
				        activate
				        display dialog "Software updates are being applied. Please do not shutdown, close the lid, or reboot your computer now. This could damage it and require a rebuild with DATA LOSS!! When the install is finished your computer will shutdown." buttons {"OK"}
				    end tell
			EOF
			/usr/sbin/softwareupdate -i -a
			sleep 30
			echo "0" > /var/db/.uitsSoftwareUpdate
			cat /var/db/.uitsSoftwareUpdate
			shutdown -h now
			
		else
		FIRST=`/usr/bin/osascript <<-EOF
		    tell application "System Events"
		        activate
		        display dialog "There are currently software updates that need to be installed. When the install is finished your computer will shutdown. Would you like to install them now?" buttons {"No","Yes"} default button 2
		    end tell
		EOF`
	
		if [ "$FIRST" == "$YES" ]; then
			echo "Uesr clicked yes first time"
			echo "Installing all updates"
			/usr/sbin/softwareupdate -i -a
			echo "0" > /var/db/.uitsSoftwareUpdate
			cat /var/db/.uitsSoftwareUpdate
			shutdown -h now
		else
			echo "User clicked no first time"
			NUM=$(($FILECOUNT + 1))
			echo $NUM > /var/db/.uitsSoftwareUpdate
			echo $NUM
			exit 1
	
		fi
	fi 
fi

exit 0