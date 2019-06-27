#!/bin/bash

ipath=/usr/local/share/dump1090-retro-html
mkdir -p $ipath

if ! dpkg -s unzip 2>/dev/null | grep 'Status.*installed' &>/dev/null
then
	apt-get update
	apt-get install -y unzip
	hash -r
fi


if [ -z $1 ] || [ $1 != "test" ]
then
	cd /tmp
	if ! wget --timeout=30 -q -O master.zip https://github.com/wiedehopf/dump1090-retro-html/archive/master.zip || ! unzip -q -o master.zip
	then
		echo "------------------"
		echo "Unable to download files, exiting! (Maybe try again?)"
		exit 1
	fi
	cd dump1090-retro-html-master
fi

cp -T -r public_html $ipath

cp 88-dump1090-retro-html.conf /etc/lighttpd/conf-available
lighty-enable-mod dump1090-retro-html >/dev/null

systemctl restart lighttpd

echo --------------
echo --------------
echo "All done!"
