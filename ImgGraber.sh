#!/bin/bash
COUNT=1
MAX=73

htmlPrefix=http://kukudm.com/comiclist/346/4704;
htmlPostfix=htm;
server=http://tt.kukudm.com:81;

indexAddress=http://kukudm.com/comiclist/346/index.htm;

function next_page_address_generator()
{
	read current_page_address
		pageNumber=`echo $current_page_address|sed -nr 's/.*\/([0-9]+)\.htm$/\1/ p'`
		echo $pageNumber >&2
		let pageNumber=pageNumber+1;
		echo $pageNumber >&2
		nextPage=`curl $current_page_address |
		iconv -f gb2312 -t utf-8 |
		sed -r "s/<[^<>]+>/\n&\n/g" |
		sed -rn "s/<a href='(\/comiclist\/[0-9]+\/[0-9]+\/$pageNumber\.htm)'>/\1/ p"` 
		echo http://kukudm.com$nextPage
}
function html_address_generator()
{
	curl $1 |
	iconv -f gb2312 -t utf-8 |
	sed -r "s/<[^<>]+>/\n&\n/g" | 
	sed -rn "s/<A href='(\/comiclist\/[0-9]+\/[0-9]+\/1.htm)' target='_blank'>/\1/ p"  |
	while read htmlAddress; do
		htmlAddress=http://kukudm.com$htmlAddress 
		echo $htmlAddress
		current=$htmlAddress
		while [ "$current" != "http://kukudm.com" ];do
			current=`echo "$current"|next_page_address_generator`
			echo $current
		done
	done

	
} 

function img_address_generator()
{
	while read htmlAddress;do
		imgLink=`curl $htmlAddress |
		iconv -f gb2312 -t utf-8 |
		sed -r "s/<[^<>]+>/\n&\n/g" |
		sed -n "/document.write(\"/,/\");/ {s/.*\"\(.*\)'>/\1/ p}" `
		
		imgLink=`echo $imgLink|tr -d '\r'`
		imgName=`echo $imgLink|sed -nr 's/.*\/([0-9]+)\/(.+)\.jpg/\1_\2.jpg/ p'`
		imgLink="$server/$imgLink"
		echo $imgLink
		echo =======$imgName========

		curl $imgLink > $imgName
	done
}

html_address_generator $indexAddress | img_address_generator;
