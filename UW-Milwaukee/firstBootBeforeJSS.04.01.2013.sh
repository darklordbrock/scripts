#!/bin/bash

######
# First boot script for JSS Production 
# Before JSS QuickAdd is run. 
# Built on 03.27.2013
#
# Kyle Brockman
# While working at UW-Milwaukee
######

#set time server
/usr/sbin/systemsetup -setnetworktimeserver time.apple.com

#set time zone
/usr/sbin/systemsetup -settimezone America/Chicago

# Get GeneratedUID of everyone 
GENUID=$(dscl . read /Groups/everyone | sed -n 's/GeneratedUID: \(.*\)/\1/p') 

# Add everyone to nested groups of _lpadmin 
dscl . append /Groups/_lpadmin NestedGroups $GENUID 

# Add everyone to nested groups of _appstore 
dscl . append /Groups/_appstore NestedGroups $GENUID 

#Create local UWM Admin Group
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localuwmadmingroup
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localuwmadmingroup name localuwmadmingroup
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localuwmadmingroup passwd "*"
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localuwmadmingroup gid 501
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localuwmadmingroup users "localadmin"

#Create local Time Machine Group
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localtimemachine
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localtimemachine name localtimemachine
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localtimemachine passwd "*"
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localtimemachine gid 502
/usr/bin/dscl -f $3/var/db/dslocal/nodes/Default localonly -create /Local/Default/groups/localtimemachine users "localadmin" 

#iCloud
#Disable iCloud as Default Save location
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

exit 0