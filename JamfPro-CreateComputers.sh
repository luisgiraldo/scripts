#!/bin/bash

# Name: 03a-createcomputers.sh
# Date: 2016/10/20
# Author: Luis Giraldo (luis@ook.co)
# Version: 1.0
# Purpose: Create computers in Jamf Pro Server from a CSV file containing a name (column 1) and serial (column 2)
#
# Script inspiration: https://www.jamf.com/jamf-nation/discussions/13118/api-and-post-command

#Define Variables
apiuser=<replacewithusername>
apipass=<replacewithpassword>
jamfProURL="https://<replacewithjamfproserverURL>:8443"
apiURL="JSSResource/computers/id/0"
xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
filepath="/path/to/sourcefile.csv"

#Backup the internal file separator
OLDIFS=$IFS
#Change the internal file separator
IFS=","

#Get number of records to process
recordqty=`awk -F, 'END {printf "%s\n", NR}' $filepath`

echo "Total records = ${recordqty}"

#Zero the counter
counter="0"
duplicates=[]

while read col1 col2
do
	counter=$[$counter+1]
	apiData="<computer><general><name>${col1}</name><serial_number>${col2}</serial_number><platform>Mac</platform></general></computer>"
	output=`curl -sSkiu ${apiuser}:${apipass} "${jamfProURL}/${apiURL}" -H "Content-Type: text/xml" -d "${xmlHeader}${apiData}" -X POST`
	#Error Checking
    	error=""
    	error=`echo $output | grep "Conflict"`
    	if [[ $error != "" ]]; then
    		echo "***Error creating record ${counter}: ${col2} ${col1}"
            duplicates+=($col2)
        else 
        	echo "Added record ${counter}: ${col2} ${col1}"
    	fi
done < "${filepath}"

if [ ${#duplicates[@]} -eq 0 ]; then
    echo "Process complete."
else
    echo "The following serial numbers could not be created:"
    printf '%s\n' "${duplicates[@]}"
fi

IFS=$OLDIFS
