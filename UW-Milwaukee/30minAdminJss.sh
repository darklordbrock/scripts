#!/bin/bash
##############
# This script will give a user 30 minutes of Admin level access, from Jamf's self service.
# At the end of the 30 minutes it will then call a jamf policy with a manual trigger. 
# Remove the users admin rights and disable the plist file this creates and activites.
# The removal script is 30minAdminjssRemoved.sh
#
# This was writen by
# Kyle Brockman
# While working for Univeristy Information Technology Servives
# at the Univeristy of Wisconsin Milwaukee
##############

U=`who |grep console| awk '{print $1}'`

# Message to user they have admin rights for 30 min. 
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "You now have admin rights to this machine for 30 minutes" buttons {"Let Me at it."} default button 1
			    end tell
			EOF

# Place launchD plist to call JSS policy to remove admin rights.
#####
echo "<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict>
	<key>Disabled</key>
	<true/>
	<key>Label</key> 
	<string>edu.uwm.uits.brockma9.adminremove</string> 
	<key>ProgramArguments</key> 
	<array> 
		<string>/usr/sbin/jamf</string>
		<string>policy</string>
		<string>-trigger</string>
		<string>adminremove</string>
	</array>
	<key>StartInterval</key>
	<integer>1800</integer> 
</dict> 
</plist>" > /Library/LaunchDaemons/edu.uwm.uits.brockma9.adminremove.plist
#####

#set the permission on the file just made.
chown root:wheel /Library/LaunchDaemons/edu.uwm.uits.brockma9.adminremove.plist
chmod 644 /Library/LaunchDaemons/edu.uwm.uits.brockma9.adminremove.plist
defaults write /Library/LaunchDaemons/edu.uwm.uits.brockma9.adminremove.plist disabled -bool false

# load the removal plist timer. 
launchctl load -w /Library/LaunchDaemons/edu.uwm.uits.brockma9.adminremove.plist

# build log files in var/uits
mkdir /var/uits
TIME=`date "+Date:%m-%d-%Y TIME:%H:%M:%S"`
echo $TIME " by " $U >> /var/uits/30minAdmin.txt

echo $U >> /var/uits/userToRemove

# give current logged user admin rights
/usr/sbin/dseditgroup -o edit -a $U -t user admin
exit 0