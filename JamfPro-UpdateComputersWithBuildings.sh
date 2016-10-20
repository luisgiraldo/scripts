#!/bin/bash

# Name: JamfPro-UpdateComputersWithBuildings.sh
# Date: 2016/10/20
# Author: Luis Giraldo (luis@ook.co)
# Version: 1.0
# Purpose: Update buildings of computers in a Jamf Pro Server from a CSV file containing a name (col1), serial (col2), and building (col3)

#Define Variables
apiuser=username
apipass=password
jamfProURL="https://JAMFPROURL:8443"
apiURL="JSSResource/computers/serialnumber"
xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
filepath="/path/to/file.csv" #where file.csv is a 3-column text file with name (col1), serial (col2), building (col3)

#Backup the internal file separator
OLDIFS=$IFS
#Change the internal file separator
IFS=","

#Get number of records to process
recordqty=`awk -F, 'END {printf "%s\n", NR}' $filepath`

echo "Total records = ${recordqty}"

#Zero the counter
counter="0"

while read col1 col2 col3
do
	counter=$[$counter+1]
	apiData="<computer><location><building>${col3}</building></location></computer>"
	curl -sSkiu ${apiuser}:${apipass} "${jamfProURL}/${apiURL}/${col2}" \
	-H "Content-Type: text/xml" \
	-d "${xmlHeader}${apiData}" \
	-X PUT > /dev/null
	echo "Placed ${col2} in building ${col3}"
done < "${filepath}"
echo "Finished!"
#Set the internal file separator back to its original value
IFS=$OLDIFS
