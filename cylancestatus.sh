#!/bin/bash

# Name: cylancestatus.sh
# Date: 2017-12-15
# Author: Luis Giraldo (@luisgiraldo)
# Version: 1.0
# Purpose: Checks for the current status of the Cylance Agent

# Define location of the Cylance status file
statusfile="/Library/Application Support/Cylance/Desktop/Status.json"

# Check for existence of the Cylance status file
if [ -f "$statusfile" ]; then
	
	# Get and trim the timestamp of the last time the agent communicated with the online service
	cylancetime=`cat "$statusfile" | grep -w last_communicated_timestamp | awk -F\" '{print $4}' | sed 's/.\{6\}$//'`
	
	# Convert the timestamp to epoch time
	cylanceepochtime=`date -j -f "%Y-%m-%dT%T" "$cylancetime" "+%s"`

	# Get the current epoch time
	currentepochtime=`date "+%s"`

	# Calculate the difference between current time and Cylance timestamp, convert to hours
	elapsedhours=$(( ($currentepochtime - $cylanceepochtime) / 3600 ))

	if (( "$elapsedhours" < 48 )); then echo "<result>Success</result>"
	elif (( "$elapsedhours" < 84 )); then echo "<result>Warning 3-5 Days</result>"
	elif (( "$elapsedhours" > 120 )); then echo "<result>Failure 5+ Days</result>"
	fi
else echo "<result>Not installed</result>"
fi
