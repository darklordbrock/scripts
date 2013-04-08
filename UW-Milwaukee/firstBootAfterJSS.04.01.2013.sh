#!/bin/bash

######
# First boot script for JSS Production 
# After JSS QuickAdd is run. 
# Built on 03.27.2013
#
# Kyle Brockman
# While working at UW-Milwaukee
######

# Add the jssworker account to local UWM admin group
dscl . append /Groups/localuwmadmingroup GroupMembership "jss"

#check for JAMF binary 
if [[  -f /usr/sbin/jamf ]]; then
	echo "jamf binary is installed"
else
	echo "jamf binary is not installed."
	exit 1	
fi

#Set the department in JSS based on machine name
DEPT=`hostname | sed 's/-/ /g' | awk '{print $1}' | tr "a-z" "A-Z"`
echo "Setting Department to: " $DEPT
/usr/sbin/jamf recon -department $DEPT

#check for any jamf policies for the machine. 
echo "check for any jamf policies"
/usr/sbin/jamf policy
sleep 3

# Trigger manual Printer installs
/usr/sbin/jamf policy -trigger printdriverBrother
sleep 2
/usr/sbin/jamf policy -trigger printdriverCanon
sleep 2
/usr/sbin/jamf policy -trigger printdriverEpson
sleep 2
/usr/sbin/jamf policy -trigger printdriverFuji
sleep 2
/usr/sbin/jamf policy -trigger printdriverGestetner
sleep 2
/usr/sbin/jamf policy -trigger printdriverHP
sleep 2
/usr/sbin/jamf policy -trigger printdriverInfo
sleep 2
/usr/sbin/jamf policy -trigger printdriverInfoTec
sleep 2
/usr/sbin/jamf policy -trigger printdriverLanier
sleep 2
/usr/sbin/jamf policy -trigger printdriverLexmark
sleep 2
/usr/sbin/jamf policy -trigger printdriverNRG
sleep 2
/usr/sbin/jamf policy -trigger printdriverRicoh
sleep 2
/usr/sbin/jamf policy -trigger printdriverSamsung
sleep 2
/usr/sbin/jamf policy -trigger printdriverSavin
sleep 2
/usr/sbin/jamf policy -trigger printdriverXerox
sleep 2

# Restore user data from Shared dir if a backup is there
BACKUP=`ls /Users/Shared/ | grep -v ".localized"`

if [[ "$BACKUP" == "" ]]; then
	echo "No Backup to restore"
	exit 0
else
	
	#check if connected to AD
	ADWORK=`id brockma9`
	if [[ "$ADWORK" == "id: brockma9: no such user" ]]; then
		echo "This machine is not connected to AD"
		exit 1
	else
		echo "Connected to AD and moving on. Nothing to see here, move along."
	fi
	
	
	#Find the users that were on the machine
	USERZ=`ls /Users/Shared/$BACKUP/ | grep -v ".localized" | grep -v ".BACKUP.plist" | grep -v ".plist"  | sed 's/-HOME.tar//g'`

	for U in $USERZ; do
		#Making the new home folder for the AD user account
		/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n $U
		/usr/sbin/createhomedir -c -u $U
		sleep 2
		
		if [[ ! -d "/Users/$U" ]]; then
			echo "Home Directory failed to be made."
			exit 1
		else
			#expand tar of the user to tmp
			mkdir /tmp/$U
			tar -xzf /Users/Shared/$BACKUP/$U-HOME.tar -C /tmp/$U
			
			#copy keychain to new users account
			#cp -f /tmp/$U/Library/Keychains/* /Users/$U/Library/Keychains/
			
			#copy the files to the new home folder 
			FILEZ=`ls -a /tmp/$U/*/*/Users/`
			for F in $FILEZ; do
				#Copy the files into the home dir
				cp -Rf /tmp/$U/$F /Users/$U/
				#Security remove the files from the tmp location
				srm -fr /tmp/$U
			done
			
			#Set Permissions on the home folders
			for P in `ls /Users/ | grep -v Shared | grep -v localadmin` ; do
				#sets owner and group to user and staff
				chown -R $P:staff /Users/$P
				#sets the folder to let the staff users in but no access
				chmod 740 /Users/$P
				#sets the user to have full access to the home dir and no one else.
				chmod -R 700 /Users/$P/*
				#Access to the public folder
				chmod 777 /Users/$P/Public
			done 
 		fi		
		
	done	
	
fi

exit 0
