#!/bin/bash
# checkTemp
# check Tokyo Temp
# mao上に置き,東京の気温データをログする
# 2019-01-09 13:07
TMP="/tmp/TokyoTempHumd"
Amedas_url="http://www.jma.go.jp/jp/amedas_h/today-44132.html?groupCode=30&areaCode=000"
Log_file="/home/yukio/TokyoTemp/log"
getTmpTime() {
	TS="`stat -c %y ${TMP}`"
	expr  ${TS:11:2}
}
printData() {
	D=`echo "$siteData" | sed -n "/time left\">$AmedasTime<\/td>/{n;s/<[^>]*>/ /g;p;}"`
	set -- $D
	ToDay="$(LC_ALL=C date +%F)"
	printf "%s,東京%s時の気温: %s°C\n" $ToDay $AmedasTime $1 >> $Log_file
}
connectError() {
	echo "$@" >> $Log_file
	exit 1
}
siteData="$(curl -f --silent ${Amedas_url})" ||\
	connectError "${ToDay},東京${AmedasTime}時 Curl connect ERROR"
AmedasTime="$(echo $siteData | sed 's/.*※\([0-9]*\)時現在.*/\1/g')"
if [ -e "$TMP" ]; then
	tmpTime="`getTmpTime`"
	if [ "$AmedasTime" != "$tmpTime" ]; then
		printData
	fi
else
	printData
fi
