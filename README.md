# spotbeefy
Shell tool to collect IP addresses of the spotify flatpack

Made for linux, currently able to grab all netstat -tulp output inside the logs/ folder and process them into a single 'blacklist'.
Will only work with netstat outputs written to a file.

This has options
 - get will perform sudo netstat -tulpa
 - init makes 2 directories. Run this if you're using this for the first time.
 - whois will perform an exact search and then a general search if there aren't any matching exact records.
