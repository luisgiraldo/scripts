#!/bin/bash

# Name: JamfPro-UpdateNames.sh
# Date: 2016/10/20
# Author: Luis Giraldo (luis@ook.co)
# Version: 1.0
# Purpose: Update names of computers in a Jamf Pro Server from a CSV file containing a name (column 1) and serial number (column 2)

#Define Variables
apiuser=username
apipass=password
jamfProURL="https://JAMFPROURL:8443"
apiURL="JSSResource/computers/serialnumber"
xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
filepath="/path/to/file.csv" #2-col CSV where col1 is the new name, col2 is the serial number

#Backup the internal file separator
OLDIFS=$IFS
#Change the internal file separator
IFS=","

#Get number of records to process
recordqty=`awk -F, 'END {printf "%s\n", NR}' $filepath`

echo "Total records = ${recordqty}"

#Zero the counter
counter="0"

while read col1 col2
do
	counter=$[$counter+1]
	apiData="<computer><general><name>${col1}</name></general></computer>"
	curl -sSkiu ${apiuser}:${apipass} "${jamfProURL}/${apiURL}/${col2}" \
	-H "Content-Type: text/xml" \
	-d "${xmlHeader}${apiData}" \
	-X PUT > /dev/null
	echo "Updated ${col2} name to ${col1}"
done < "${filepath}"
echo "${counter} record/s updated!"
#Set the internal file separator back to its original value
IFS=$OLDIFS
