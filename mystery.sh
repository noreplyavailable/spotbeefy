#!/bin/bash

arg1=$1

get_netstat() {
	sudo netstat -tulpaen > logs/NETSTAT_latest
}

post_help() {
	echo "*** The unofficial tool for taking a look at where the linux spotify flatpack sends it's data ***"
	echo
	echo "Syntax:"
	echo "./china.sh [init/get/whois] "
	echo "init should be run before running it for the first time"
	echo
	echo "[get]"
	echo "get would be the most used argument. This will run the netstat command and process it into the blacklist "
	echo "optional because you might want to manually add IP addresses into the logs/ folder and still process them into the blacklist"
	echo
	echo "[whois]"
	echo "whois will perform a whois search on all ip addresses in the blacklist"
	echo "It will first try a exact match then a general match if there were none"
	echo
}

init_china() {
	mkdir logs
	mkdir whois
}

process() {
	touch temp1a
	for o in $(ls logs/); do
		cat logs/$o -E >> temp1a
	done

	touch temp1
	grep -E 'spotify|debug' temp1a > temp1
	rm temp1a

	local num=$(echo $(cat temp1 -n | tail -n1 | cut -d ' ' -f5) | cut -d ' ' -f1)

	touch temp2
	for i in $(seq 1 $num); do
		echo $(cat temp1 -n) | cut -d '$' -f$i | cut -d ' ' -f7 | grep -v '*' | grep -v 'ESTABLISHED' | grep -v 'LISTEN' | cut -d . -f1-4 | grep -v ':::' | cut -d : -f1 >> temp2
	done
	rm temp1
	touch blacklist
	for i in $(cat temp2); do
		if [[ $i != $(cat blacklist | grep $i -o) && $i != 192.168.* ]]; then
			echo $i >> blacklist
			echo "New IP address found: $i"
		fi
	done
	rm temp2

}

mass_whois() {
	echo "Checking whois db for all blacklisted ip addresses...."
	echo "...."
	for y in $(cat blacklist); do
		echo $y
		if [[ $y == $(ls whois/ | grep -o $y) ]]
		then
			continue
		fi
		if [[ $(whois -x $y | grep '101: no entries found' -o) != '101: no entries found' ]]
		then
			echo "Exact match found for $y!"
			whois $y -x > whois/EXACT_WHOIS--$y
		fi
		if [[ $(whois $y | grep '101: no entries found' -o) != '101: no entries found' ]]
		then
			echo "General match found for $y"
			whois $y > whois/_WHOIS--$y
		fi
		echo "Checking radb.net for $y."
		curl https://www.radb.net/query?keywords=$y -s | grep : -n | grep 43 >> whois/_WHOIS--$y
		echo
	done
	echo "Finished"

}

case $arg1 in
	init)
		init_china
		;;
	get)
		get_netstat
		;;
	whois)
		mass_whois
		;;
	*)
		post_help
		;;
esac
process
