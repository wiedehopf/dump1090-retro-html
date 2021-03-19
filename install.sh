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
cp LICENSE $ipath

rm -f /etc/lighttpd/conf-enabled/89-dump1090.conf
cp 88-dump1090-retro-html.conf /etc/lighttpd/conf-available
lighty-enable-mod dump1090-retro-html >/dev/null

srcdir=/run/dump1090-fa/

if [[ -f /run/dump1090-fa/aircraft.json ]]; then
    srcdir=/run/dump1090-fa/
elif [[ -f /run/readsb/aircraft.json ]]; then
    srcdir=/run/readsb/
elif [[ -f /run/adsbexchange-feed/aircraft.json ]]; then
    srcdir=/run/adsbexchange-feed/
elif [[ -f /run/dump1090/aircraft.json ]]; then
    srcdir=/run/dump1090/
elif [[ -f /run/dump1090-mutability/aircraft.json ]]; then
    srcdir=/run/dump1090-mutability/
fi

sed -i -e "s?SRCDIR?$srcdir?g" /etc/lighttpd/conf-available/88-dump1090-retro-html.conf

systemctl restart lighttpd

echo --------------
echo --------------
echo "All done! Webinterface available at http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*')/dump1090"
