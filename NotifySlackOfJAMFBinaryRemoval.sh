#!/bin/bash

# This script should be called by a launch daemon that checks for existence of the JAMF binary.
# A launch daemon like rtrouton's Casper Check (modified to call this script) could be used for this.
# Casper Check: https://github.com/rtrouton/CasperCheck

# Script Author: Luis Giraldo @luisgiraldo

#Check for Computer's Hostname
compHostname=`/bin/hostname`

#Get Computer Serial Number
compSerial=`/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4; }'`

#Generate a link for JSS Search
JSSSearchURL="https://yourjssurl.example.com:8443/computers.html?queryType=Computers&query="$compSerial

#Get Watchman Monitoring ID
WMID=`/usr/bin/defaults read /Library/MonitoringClient/ClientSettings WatchmanID`

#Generate Link for Watchman Monitoring Computer Record
WMComputer="https://app.monitoringclient.com/computers/"$WMID

#Using Watchman Monitoring ID, generate Monkey Box Lookup Link
MonkeyBoxURL="https://app.monkeybox.com/lookup?wm_client="$WMID

#Alternate MonkeyBoxURL (Provides a search result, as opposed to direct computer link)
#MonkeyBoxURL="https://app.monkeybox.com/accounts/1/search?q="$compSerial"&commit=Go"

#Title of message for Slack notification
msgTitle="*JAMF Framework removed from computer!*"

#Body of message for Slack notification
msgBody="Serial: <"$JSSSearchURL"|"$compSerial">"

#URL of Slack Incoming WebHook - https://my.slack.com/services/new/incoming-webhook/
slackUrl="https://hooks.slack.com/services/randomstring/randomstring/randomstring"

#URL of Image to use for Notification Icon - use a square image
iconURL="https://www.example.com/image.png"

read -d '' payLoad << EOF
{
        "icon_url": "$iconURL",
        "text": "${msgTitle}",
        "attachments": [
            {
                "fallback": "Please review the details below:",
                "color": "warning",
                "fields": [
                	{
                    	"title": "Hostname:",
                    	"value": "${compHostname}",
                    	"short": true
                	},
                	{
						"title": "Serial:",
						"value": "${compSerial}",
						"short": true
                	},
                    {
						"title": "View in:",
						"value": "<${JSSSearchURL}|JSS> • <${MonkeyBoxURL}|Monkey Box> • <${WMComputer}|Watchman Monitoring>",
						"short": false
                    }
                	]
            }
        ]
    }
EOF

statusCode=$(curl \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${slackUrl})

echo ${statusCode}
exit 0