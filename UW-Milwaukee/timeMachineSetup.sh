#!/bin/bash
##############
# This Script will allow a user to select the drive they would like to use for encrypted time mechine. 
# It will then reformat the partition if it is needed, and/or repartition the drive to GUID if needed.
# The user does not need to be an admin or have access to the Time Machine Preference Panel. 
#
# This was writen by
# Kyle Brockman
# While working for Univeristy Information Technology Servives
# at the Univeristy of Wisconsin Milwaukee
##############


YES=`echo "button returned:Yes"`
NO=`echo "button returned:No"`

echo $YES "test1"
echo $NO "test2"

#applescipt to ask which drive to enable Time Machine on. 

TMD=`/usr/bin/osascript <<-EOF
set fileLists to paragraphs of (do shell script "ls /Volumes/ | grep -v 'Macintosh HD' | grep -v 'JSS_Repo'")
    tell application "System Events"
        activate
        choose from list fileLists
    end tell
EOF`

echo $TMD

#check if the user clicks cancel, if cancel clicked the script quits 

if [ "$TMD" == "false" ] ; then
	echo "User clicked Cancel"
	exit 1
	
else
	
	echo "User Selected " $TMD " as their Time Machine Drive"
	
	TMDRECORD=`diskutil info $TMD | grep "Partition Type:" | awk '{print $3}'`
	TMDFORMAT=`diskutil info $TMD | grep "File System Personality:" | awk '{print $4 $5}'`
	DISK=`diskutil info $TMD | grep "Part of Whole:" | awk '{print $4}'`
	COREDISK=`diskutil corestorage info $DISK | grep "Conversion Status:" | awk '{print $3}'`
	
	echo "Time Machine Drive Selected Partition Type: " $TMDRECORD
	echo "Time Machine Drive Selected File System Personality: " $TMDFORMAT
	echo "Time Machine Drive Selected Part of Disk: " $DISK
	
	if [ "$COREDISK" == "Complete" ]; then
		echo "Disk is already encrypted"
		
		echo "tmutil setdestination"
		tmutil setdestination /Volumes/$TMD

		echo "tmutil enable for automatic backups"
		tmutil enable

		echo "tmutil enable local snapshots"
		tmutil enablelocal
		
		exit 0
	else
		echo "Disk is not already encrypted"
	fi
	
	
	if [ "$TMDRECORD" != "Apple_HFS" ] ; then
		
			#ask the users are they really sure
			FIRST=`/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "The drive you have selected needs to be re-formatted to be used with Time Machine. Do you want to re-format it?" buttons {"Yes","No"} default button 2
			    end tell
			EOF`

			if [ "$FIRST" == "$YES" ]; then
				echo "Uesr clicked yes first time"
			else
				echo "User clicked no first time"
				exit 1
			fi

			#do you want me to format X
		
			SECOND=`/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "All data on this drive will be lost when it is re-formatted. Are you sure you want it re-formatted?" buttons {"Yes","No"} default button 2
			    end tell
			EOF`

			if [ "$SECOND" == "$YES" ]; then
				echo "Uesr clicked yes second time"
			else
				echo "User clicked no second time"
				exit 1
			fi

			#are you really sure
		
			THIRD=`/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Are you really sure you want re-format the disk? All data on this drive will be erased after you click yes." buttons {"Yes","No"} default button 2
			    end tell
			EOF`

			if [ "$THIRD" == "$YES" ]; then
				echo "Uesr clicked yes third time"
			else
				echo "User clicked no third time"
				exit 1
			fi

			#are you really really sure
		
			#FOURTH=`/usr/bin/osascript <<-EOF
			#    tell application "System Events"
			#        activate
			#        display dialog "Are you REALLY REALLY sure you want me to erase everything on this drive? There is NO going back after click yes." buttons {"Yes","No"} default button 2
			#    end tell
			#EOF`

			#if [ "$FOURTH" == "$YES" ]; then
			#	echo "Uesr clicked yes fourth time"
			#else
			#	echo "User clicked no fourth time"
			#	exit 1
			#fi
		
			diskutil eraseDisk JHFS+ $TMD $DISK
			echo "drive was formated Journaled HFS+ and repartitioned to GUID"
			
	else
		
		if [ "$TMDFORMAT" != "JournaledHFS+" ] ; then
			#ask the users are they really sure
			FIRST=`/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "The drive you have selected needs to be re-formatted to be used with Time Machine. Do you want to re-format it?" buttons {"Yes","No"} default button 2
			    end tell
			EOF`

			if [ "$FIRST" == "$YES" ]; then
				echo "Uesr clicked yes first time"
			else
				echo "User clicked no first time"
				exit 1
			fi

			#do you want me to format X
		
			SECOND=`/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "All data on this drive will be lost when it is re-formatted. Are you sure you want it re-formatted?" buttons {"Yes","No"} default button 2
			    end tell
			EOF`

			if [ "$SECOND" == "$YES" ]; then
				echo "Uesr clicked yes second time"
			else
				echo "User clicked no second time"
				exit 1
			fi

			#are you really sure
		
			THIRD=`/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Are you really sure you want re-format the disk? All data on this drive will be erased after you click yes." buttons {"Yes","No"} default button 2
			    end tell
			EOF`

			if [ "$THIRD" == "$YES" ]; then
				echo "Uesr clicked yes third time"
			else
				echo "User clicked no third time"
				exit 1
			fi

			#are you really really sure
		
			#FOURTH=`/usr/bin/osascript <<-EOF
			#    tell application "System Events"
			#        activate
			#        display dialog "Are you REALLY REALLY sure you want me to erase everything on this drive? There is NO going back after click yes." buttons {"Yes","No"} default button 2
			#    end tell
			#EOF`

			#if [ "$FOURTH" == "$YES" ]; then
			#	echo "Uesr clicked yes fourth time"
			#else
			#	echo "User clicked no fourth time"
			#	exit 1
			#fi
		
			diskutil erase $TMD JHFS+
			echo "Partition reformated to JHFS+"
			
		else
		
			echo "drive is Journaled HFS+ and GUID partitioned"
	
		fi
	fi
PASSONE="1"
PASSTWO="2"

while [ $PASSONE != $PASSTWO ];do


	#Sets the nothing variable 
	
	NOTHING1="1"
	#input from user on password for the drive
	
	while [ $PASSONE -eq $NOTHING1 ]; do
		PASSONE=`/usr/bin/osascript <<-EOF
		    tell application "System Events"
		        activate
				display dialog "Enter password for Time machine Drive " default answer "1" buttons {"Continue…"} default button 1
				set theAnswer to (text returned of result)
		    end tell
		EOF`
	done

	#echo $PASSONE
	
	NOTHING2="2"
	#verify password from the user for the drive
		while [ $PASSTWO -eq $NOTHING2 ]; do
		PASSTWO=`/usr/bin/osascript <<-EOF
		    tell application "System Events"
		        activate
				display dialog "Re-enter password for Time machine Drive " default answer "2" buttons {"Continue…"} default button 1
				set theAnswer to (text returned of result)
		    end tell
		EOF`
	done

	#echo $PASSTWO

	if [ $PASSONE != $PASSTWO ]; then
		PASSONE="1"
		PASSTWO="2"
		
	else
		
		echo "they matched passwords"
	fi
	
done

echo "Users password verified and beginning encryption"

#Convert the drive to encrypted
diskutil cs convert /Volumes/$TMD -passphrase $PASSONE  

#setup time machine to use the drive
echo "tmutil setdestination"
tmutil setdestination /Volumes/$TMD

echo "tmutil enable for automatic backups"
tmutil enable

echo "tmutil enable local snapshots"
tmutil enablelocal

#setup time machine exclusions (only backing up /Users)
#echo "setup exclusions"
#tmutil addexclusion /System /Library /Applications /var /etc /Developer /Groups /Incompatible\ Software /Volumes /bin /cores /usr /tmp /temp /opt /net /home /Shared\ Items /Network /Groups

fi

exit 0