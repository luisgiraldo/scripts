#!/bin/bash

# Name: JamfPro-CreateBuildings.sh
# Date: 2016/10/20
# Author: Luis Giraldo (luis@ook.co)
# Version: 1.0
# Purpose: Create buildings in a Jamf Pro Server from a CSV file containing a building name on each line.

#Define Variables
apiuser=username
apipass=password
jssURL="https://JAMFPROURL.priv:8443"
apiURL="JSSResource/buildings/id/0"
xmlheader="<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
filepath="/path/to/file.csv" #Where file.csv contains a list of buildings, one per line

#Get number of records to process
recordqty=`awk -F, 'END {printf "%s\n", NR}' $filepath`

echo "Total records = ${recordqty}"

#Zero the counter
counter="0"

while read line
do
	counter=$[$counter+1]
	apiData="<building><name>${line}</name></building>"
	curl -sSkiu ${apiuser}:${apipass} "${jssURL}/${apiURL}" \
	-H "Content-Type: text/xml" \
	-d "${xmlheader}${apiData}" \
	-X POST
done < "${filepath}"
echo "Finished!"
