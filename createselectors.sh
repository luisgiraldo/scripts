#/bin/bash

# This script will use cli53 to create the DNS selector records required for DKIM signing with Microsoft 365.
# Script Author: Luis Giraldo @luisgiraldo

# Requirements: cli53 (https://github.com/barnybug/cli53)

# Let's get the customer domain name
echo "What is the full domain name? e.g. example.com"
read domainName

# Let's get the customer initial domain
echo "What is the initial domain host? e.g. example.onmicrosoft.com would be 'example'"
read initialDomain

# Create a new variable from the domain replacing periods for hyphens
hyphenDomain="${domainName//./-}"


# Create the selectors
echo "Creating selector1..."
cli53 rrcreate $domainName 'selector1._domainkey 300 CNAME selector1-'$hyphenDomain'._domainkey.'$initialDomain'.onmicrosoft.com.'
echo "Creating selector2..."
cli53 rrcreate $domainName 'selector2._domainkey 300 CNAME selector2-'$hyphenDomain'._domainkey.'$initialDomain'.onmicrosoft.com.'

# Return the full zone file for confirmation
echo "Here's the complete zone file:"
echo "========================================="
cli53 export $domainName
echo "========================================="